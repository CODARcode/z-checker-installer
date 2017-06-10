#!/usr/bin/env python

import sys
import os
import glob
import string
import re
import subprocess
import shutil
import json
import SimpleHTTPServer
import SocketServer

current_path = os.getcwd()
test_case = sys.argv[1]

case_path = current_path + "/Z-checker/" + test_case
dest_path = case_path + "/report/web"

gnuplot_executable = current_path + "/gnuplot-5.0.6-install/bin/gnuplot"

rpath_dp = "/dataProperties"
rpath_cp = "/compressionResults"
rpath_cc = "/compareCompressors/data"

input_path = case_path + "/report/figs"
input_path_dp = input_path + rpath_dp
input_path_cp = input_path + rpath_cp
input_path_cc = input_path + "/compareCompressors/gnuplot_scripts"
input_path_cc_data = input_path + rpath_cc

try: 
    os.makedirs(dest_path)
except:
    pass

def generateFigureForZChecker(filename, cwd):
    key = re.sub("\.", '_', os.path.basename(filename)[:-2]);

    script = ""
    script1 = ""
    with open (filename, "r") as script_file:
        script = script_file.read()

    for line in script.split("\n"):
        if line.startswith("#") or line.startswith("set size"):
            continue
        elif line.startswith("set term"):
            script1 += "set terminal svg enh\n";
        elif line.startswith("set output"):
            script1 += 'set output "' + key + '.svg' + '"\n';
        else:
            script1 += line + "\n";

    try: 
        process = subprocess.Popen([gnuplot_executable], cwd=cwd, stdin=subprocess.PIPE)
        process.communicate(input=script1)
        process.wait()

        shutil.copyfile(cwd + "/" + key + ".svg", dest_path + "/" + key + ".svg")
    except: 
        print "Oops.. Gnuplot failed."
        pass

    return key


def generateDataPropertiesTab():
    print "generating image files for dataProperties..."
    outputs = []
    
    files_dp = glob.glob(input_path_dp + "/*.p")
    for f in files_dp:
        key = generateFigureForZChecker(f, input_path_dp)
        varname = ""
        property = ""

        if key.endswith("-autocorr"):
            varname = key[:-9]
            property = "autocorr"
        elif key.endswith("-fft-amp"):
            varname = key[:-8]
            property = "fft-amp"

        outputs.append(dict({
            "key": key, 
            "filename": key + ".svg",
            "varname": varname,
            "property": property
        }))

    return outputs

def generateCompressionResultsTab():
    print "generating files for compressionResults..."
    outputs = []
    
    files_cp = glob.glob(input_path_cp + "/*.p")
    for f in files_cp:
        key = generateFigureForZChecker(f, input_path_cp)
        varname = ""
        property = ""

        strs = key.split(":")
        prefix = strs[0]
        postfix = strs[1]
   
        bound = re.search("\(([^)]+)\)", prefix).group(1)
        compressor = prefix.split("(")[0]
        
        if postfix.endswith("-autocorr"):
            varname = postfix[:-9]
            property = "autocorr"
        elif postfix.endswith("-fft-amp"):
            varname = postfix[:-8]
            property = "fft-amp"
        elif postfix.endswith("-dis"):
            varname = postfix[:-4]
            property = "dis"
       
        key1 = re.sub("\(|\)|\:", '_', key)
        outputs.append(dict({
            "key": key1,
            "filename": key + ".svg",
            "compressor": compressor,
            "bound": bound,
            "varname": varname,
            "property": property
        }))

    return outputs


def generateComparisonResultsTab():
    print "generating files for compareCompressors..."
    outputs = []
    
    files_cc = glob.glob(input_path_cc + "/*.p")
    for f in files_cc:
        key = generateFigureForZChecker(f, input_path_cc_data)
        
        outputs.append(dict({
            "key": key,
            "filename": key + ".svg"
        }))

    return outputs

def saveJson(filename, data): 
    with open(filename, 'w') as fp:
        json.dump(data, fp)

saveJson(dest_path + "/dataProperties.json", generateDataPropertiesTab())
saveJson(dest_path + "/compressionResults.json", generateCompressionResultsTab())
saveJson(dest_path + "/compareCompressors.json", generateComparisonResultsTab())

for f in glob.glob("./public/*"):
    print "copying", f
    shutil.copy(f, dest_path)

os.chdir(dest_path)
httpd = SocketServer.TCPServer(("", 8087), SimpleHTTPServer.SimpleHTTPRequestHandler)
print "Please visit http://localhost:8087"
print "Press Ctrl+C to exit the server"
httpd.serve_forever()

