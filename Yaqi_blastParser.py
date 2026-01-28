#!/usr/bin/env python3

"""
Author: Yaqi Jiao
Date: 27th January, 2026

blastParser.py
--------------

Description:
This python script
The script performs the following operations:
    1. Read a blastp input file containing blast results
    2. Extract query, target, e-value, identity and score from the file
    3. When a query returns multi hits, if they have alignment and score, also show them with same query
    4. the output file name is determined by user, if no output name, the default name is: output.txt

Input file: yeast_vs_Paxillus.blastp
Output file (optional): output.txt
    
Usage Example: blastParser.py yeast_vs_Paxillus.blastp <output file>

"""

# Package Preparation
import sys
import re


def parser(blast_file):
    # set empty list and variable to store data
    results = []

    current_query = None
    current_target = None
    current_score = None
    current_evalue = None
    current_identity = None

    # read line by line, remove space, \n and \t
    for line in blast_file:
        line = line.strip()
        if not line:
            continue

        # determine query line
        if line.startswith("Query="):
            current_query = line.split()[1]
        
        if ("No hits found") in line:
            results.append((
                    current_query, "", "", "", ""
                )) 
            

        if line.startswith(">"):
            current_target = line[1:].strip()
        
        if "Score" in line and "Expect" in line:
            score_match = re.search(r"Score =\s+([\d\.]+)", line)
            evalue_match = re.search(r"Expect =\s*([^\s,]+)", line)

            if score_match and evalue_match:
                current_score = score_match.group(1)
                current_evalue = evalue_match.group(1)
        
        if "Identities" in line:
            identity_match = re.search(r"Identities = \d+/\d+ \((\d+)%\)", line)
            # only consider hits with scores and identities
            if identity_match and current_query and current_target and current_score:
                current_identity = identity_match.group(1)
                
                results.append((
                    current_query,
                    current_target,
                    current_evalue,
                    current_identity,
                    current_score
                ))

            # prepare for next hit
            current_target = None
            current_score = None
            current_evalue = None
            current_identity = None

    return results


# main logic
def main():
    if len(sys.argv) < 2:
            print("Usage: blastParser.py <blast_output> [output_file]")
            sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else "output.txt"

    with open(input_file) as f:
        results = parser(f)

    with open(output_file, "w") as out:
        out.write("#query\ttarget\te-value\tidentity(%)\tscore\n")
        for row in results:
            out.write("\t".join(row) + "\n")


if __name__ == "__main__":
    main()