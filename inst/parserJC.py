#!/usr/bin/python3
# -*- coding: utf-8 -*-
from collections import OrderedDict
import subprocess
import os
import json
#JC
import sys
# sys.setdefaultencoding() does not exist, here!
reload(sys)  # Reload does the trick!
sys.setdefaultencoding('UTF8')
#/JC
#
ROOT_DIR = os.path.expanduser(sys.args[1]) 
PARSER_EVAL = ROOT_DIR +'bazel-bin/syntaxnet/parser_eval'
#MODEL_DIR = 'syntaxnet/models/parsey_mcparseface'
MODELS_DIR = ROOT_DIR+'syntaxnet/models/'
CONTEXT = ROOT_DIR+'syntaxnet/models/parsey_universal/context.pbtxt'

#ENV VARS:
#MODELS = [l.strip() for l in os.getenv('PARSEY_MODELS', 'English').split(',')]
#MODELS=['English', 'Spanish-AnCora']
#MODELS=['English']
BATCH_SIZE = os.getenv('PARSEY_BATCH_SIZE', '1')

def split_tokens(parse):
  # Format the result.
  def format_token(line):
    x = OrderedDict(zip(
     ["id", "form", "lemma", "upostag", "xpostag", "feats", "head", "deprel", "deps", "misc"],
     line.split("\t")
    ))
    for key, val in x.items():
        if val == "_": del x[key] # = None
    x['id'] = int(x['id'])
    x['head'] = int(x['head'])
    if x['feats']:
        feat_dict = {}
        for feat in x['feats'].split('|'):
            split_feat = feat.split('=')
            feat_dict[split_feat[0]] = split_feat[1]
        x['feats'] = feat_dict
    return x

  return [format_token(line) for line in parse.strip().split("\n")]

def make_tree(split_tokens, sentence):
    tokens = { tok["id"]: tok for tok in split_tokens }
    tokens[0] = OrderedDict([ ("sentence", sentence) ])
    for tok in split_tokens:
       tokens[tok['head']]\
         .setdefault('tree', OrderedDict()) \
         .setdefault(tok['deprel'], []) \
         .append(tok)
       del tok['head']
       del tok['deprel']

    return tokens[0]

def conll_to_dict(conll):
    conll_list = conll.strip().split("\n\n")
    return map(split_tokens, conll_list)

def open_parser_eval(args):
  return subprocess.Popen(
    [PARSER_EVAL] + args,
    cwd=ROOT_DIR,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE
  )

def send_input(process, input_str, num_lines):
#  print("sending input: %s, %s" % (input_str, num_lines))
  input_str = input_str.encode('utf8')
  process.stdin.write(input_str)
  process.stdin.write(b"\n\n") # signal end of documents
  process.stdin.flush()
  response = b""
  while num_lines > 0:
    line = process.stdout.readline()
  #  print("line: %s" % line)
    if line.strip() == b"":
      # empty line signals end of output for one sentence
      num_lines -= 1
    response += line
  return response.decode('utf8')

def create_pipeline(model):
    model_dir = MODELS_DIR + model

    # tokenizer = open_parser_eval([
    #     "--input=stdin-untoken",
    #     "--output=stdout-conll",
    #     "--hidden_layer_sizes=128,128",
    #     "--arg_prefix=brain_tokenizer",
    #     "--graph_builder=greedy",
    #     "--task_context=%s" % CONTEXT,
    #     "--resource_dir=%s" % model_dir,
    #     "--model_path=%s/tokenizer-params" % model_dir,
    #     "--slim_model",
    #     "--batch_size=32",
    #     #"--batch_size=1",
    #     "--alsologtostderr"
    # ])

    # Open the morpher
    morpher = open_parser_eval([
        "--input=stdin",
        "--output=stdout-conll",
        "--hidden_layer_sizes=64",
        "--arg_prefix=brain_morpher",
        "--graph_builder=structured",
        "--task_context=%s" % CONTEXT,
        "--resource_dir=%s" % model_dir,
        "--model_path=%s/morpher-params" % model_dir,
        "--slim_model",
        "--batch_size=%s" % BATCH_SIZE,
        "--alsologtostderr"])

    # Open the part-of-speech tagger.
    pos_tagger = open_parser_eval([
        "--input=stdin-conll",
        "--output=stdout-conll",
        "--hidden_layer_sizes=64",
        "--arg_prefix=brain_tagger",
        "--graph_builder=structured",
        "--task_context=%s" % CONTEXT,
        "--resource_dir=%s" % model_dir,
        "--model_path=%s/tagger-params" % model_dir,
        "--slim_model",
        "--batch_size=%s" % BATCH_SIZE,
        "--alsologtostderr"])

    # Open the syntactic dependency parser.
    dependency_parser = open_parser_eval([
        "--input=stdin-conll",
                "--output=stdout-conll",

        "--hidden_layer_sizes=512,512",
        "--arg_prefix=brain_parser",
        "--graph_builder=structured",
        "--task_context=%s" % CONTEXT,
        "--resource_dir=%s" % model_dir,
        "--model_path=%s/parser-params" % model_dir,
        "--slim_model",
        "--batch_size=%s" % BATCH_SIZE, 
        "--alsologtostderr"])

    return [morpher, pos_tagger, dependency_parser]

#brain process pipelines:
def parse_sentences(sentences, request_args):
  sentences = sentences.strip() + '\n'
  num_lines = sentences.count('\n')

  #lang = request_args.get('language', default=MODELS[0])
  pipeline = pipelines[request_args]

  # print("TOKENIZER! %s, %s" % ( sentences, num_lines))
  # print(send_input(pipeline[3], sentences, num_lines))

  # Do the morphing
  morphed = send_input(pipeline[0], sentences, num_lines)
  # Do POS tagging.
  pos_tags = send_input(pipeline[1], morphed, num_lines)
  # Do syntax parsing.
  dependency_parse = send_input(pipeline[2], pos_tags, num_lines)

  #print(dependency_parse)

  #return [make_tree(st, sen) for sen, st in zip(sentences.split("\n"), split_tokens_list)]
  return conll_to_dict(dependency_parse)

#if __name__ == "__main__":
 # import sys, pprint
  #pprint.pprint(parse_sentence(sys.stdin.read().strip())["tree"])
pipelines = {}
def parseVector(languageModel, vector,  output):
    sys.stderr.write( "== Starting pipeline  ==\n")
    global pipelines
    pipelines[languageModel] = create_pipeline(languageModel)
    result=[]
    sys.stderr.write( "== Reading vector file  ==\n")
    with open(vector, 'r') as input:
        tokens=input.readlines()
    sys.stderr.write("== Parsing tokens  ==\n")
    for token in tokens:
        token=str(token)
        result.append(parse_sentences(token.decode('utf-8').strip(), languageModel))
    sys.stderr.write("== All tokens parsed, dumping results to JSON ==\n")
    with open (output, 'w')  as out:
        out.write(json.dumps(result)) 
    sys.stderr.write("== DONE ==\n")
    return "done"
 
