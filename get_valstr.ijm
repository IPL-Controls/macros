//The input argument string is the name of the variable to look for, followed by ",", followed by the
//	the string to search. Returns a string containing all values of the instances of the variable,
//	separated by ",".
//HW 2-25-2014


macro "get_valstr"{
argStr = getArgument();
argStrArr = split(argStr,",\n\r");
//print(argStrArr.length);
//Array.print(argStrArr);
var_name=argStrArr[0]; //variable name is the leading block.

nArgs = argStrArr.length;
valStr = "";
cnt = 0;

for(i=1;i<nArgs;i++){
	thisStr = argStrArr[i];
	if(indexOf(thisStr,var_name) >= 0){
		strL = lengthOf(thisStr);
		if(cnt == 0){
				valStr = substring(thisStr,indexOf(thisStr, "=")+1, strL);
			}
		else{
			valStr = valStr+","+substring(thisStr,indexOf(thisStr, "=")+1, strL);
		}
		cnt += 1;
	}
	}
return valStr;
}


