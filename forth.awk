#!/usr/bin/igawk -f
function parse(line,	word, wordline, len, w) {

	len = split(line, wordline);

	for (w = 1; w <= len; w++) {
		word = wordline[w];

		if (COMPILING) {
			if (word ~ /\;/) {
				words[newword] = code;	
				COMPILING=0;
				code = "";
				newword = "";
			} else if (newword) {
				code = code " " word;
			} else {
				newword = word;
			}
		} else if (word in words) {
			parse(words[word]);	
		} else if (word ~ /[0-9]/) { 
			stack[sp++] = word;
		} else if (word ~ /+/) {
			rop = stack[--sp];
			lop = stack[--sp];
			stack[sp++] = lop + rop;
		} else if (word ~ /-/) {
			rop = stack[--sp];
			lop = stack[--sp];
			stack[sp++] = lop - rop;
		} else if (word ~ /*/) {
			rop = stack[--sp];
			lop = stack[--sp];
			stack[sp++] = lop * rop;
		} else if (word ~ /\//) {
			rop = stack[--sp];
			lop = stack[--sp];
			stack[sp++] = lop / rop;
		} else if (word ~ /\./) {
			print stack[--sp];
		} else if (word ~ /DROP/) {
			op = stack[--sp];
		} else if (word ~ /DUP/) {
			op = stack[sp - 1];
			stack[sp++] = op;
		} else if (word ~ /SWAP/) {
			first = stack[--sp];
			second = stack[--sp];
			stack[sp++] = first;
			stack[sp++] = second;
		} else if (word ~ /SEE/) {
			if (w < len) {
				w++
				if (wordline[w] in words) {
					print ":", wordline[w], words[wordline[w]], ";";
				} else {
					print "undefined word";
				}
			} else {
				print "unspecified word";
			}
		} else if (word ~ /\:/) {
			COMPILING=1;
		} else if (word ~ /BYE/) {
			exit;
		}
	}
}

{ # for every line
	parse($0);
}


