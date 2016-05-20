// hintsnet 寮曟€濈綉涓撶敤搴撳嚱鏁�

// 瀹氫箟 CJK 瀛楃鐩稿叧姝ｅ垯琛ㄨ揪寮�
var regExpEn = "[a-zA-Z0-9-]";
var regExpCJKIdeographs = "[銗€-\u4dbe涓€-\u9ffe]|[\ud840-\ud868\ud86a-\ud86c][\udc00-\udfff]|\ud869[\udc00-\udede\udf00-\udfff]|\ud86d[\udc00-\udf3e\udf40-\udfff]|\ud86e[\udc00-\udc1e]|[\ufa0e\ufa0f\ufa11\ufa13\ufa14\ufa1f\ufa21\ufa23\ufa24\ufa27-\ufa29]";
var regExpCJKSymbols = "[\u3000-銆撅紵锛屻€佲€溾€濃€樷€欙紙锛夈€娿€嬧€斅穄";

function hintPipeIsEqual(hintPipeA, hintPipeB) {
  if (hintPipeA["inPort"] === hintPipeB["inPort"] &&
    hintPipeA["outPort"] === hintPipeB["outPort"]) {
    return true;
  } else {
    return false;
  }
}

// 鎶婂紩鎬濈閬撲粠瀛楃涓叉弿杩拌浆鎹负 JS 瀵硅薄
function hintPipeStr2Obj(hintPipeStr) {
  var portLabelPattern = regExpEn + "|" + regExpCJKIdeographs + "|" + regExpCJKSymbols;
  var hintPipePattern =
    "((" + portLabelPattern + ")+)" +
    "\\|->\\|" +
    "((" + portLabelPattern + ")+)";
  var hintPipeObj = {};
  var regExpForhintPipe = new RegExp(hintPipePattern, "g");
  var regExpMatchResult = regExpForhintPipe.exec(hintPipeStr);

  if (regExpMatchResult != null) {
    hintPipeObj = {
      "inPort": regExpMatchResult[1],
      "outPort": regExpMatchResult[3]
    };
  } else {;
  }
  return hintPipeObj;
}

// 鎶婂紩鎬濈閬撳ぇ娈垫枃鏈殑姣忎釜鍏冪礌閮戒粠瀛楃涓叉弿杩拌浆鎹负 JS 瀵硅薄
function hintPipeText2ObjArray(hintPipeText) {
  hintPipeStrArray = hintPipeText.split('\n');
  var hintPipeObjArray = [];
  for (hintPipeStr of hintPipeStrArray) {
    if (hintPipeStr.trim() != "") {
      hintPipeObjArray.push(hintPipeStr2Obj(hintPipeStr.trim()));
    } else {;
    }
  }
  return hintPipeObjArray;
}

// 鎶婂紩鎬濈閬撲粠 JS 瀵硅薄杞崲涓� Dot 璇硶鎻忚堪
function hintPipeObj2DotEdge(hintPipeObj) {
  var DotEdge = "";
  if (isEmpty(hintPipeObj) === false) {
    DotEdge = '  "' + hintPipeObj["inPort"] + '" -> "' + hintPipeObj["outPort"] + '"\n';
  } else {;
  }
  return DotEdge;
}

// 鎶婂紩鎬濈閬撳簭鍒楃殑姣忎釜鍏冪礌閮戒粠 JS 瀵硅薄杞崲涓� Dot 璇硶鎻忚堪瀛楃涓�
function hintPipeObjArray2DotEdges(hintPipeObjArray) {
  var DotEdges = "";
  for (hintPipeObj of hintPipeObjArray) {
    DotEdges += hintPipeObj2DotEdge(hintPipeObj);
  }
  return DotEdges;
}

// 鎶婂紩鎬濈閬撳簭鍒楄浆鎹负 Dot 璇硶鎻忚堪瀛楃涓�
function hintPipeText2DotEdges(hintPipeText) {
  var hintPipeObjArray = hintPipeText2ObjArray(hintPipeText);
  return hintPipeObjArray2DotEdges(hintPipeObjArray);
}

// 涓� Dot 璇硶鎻忚堪瀛楃涓插姞涓� digraph 鐨勫鍖呰９
function dotEdges2Digraph(dotEdges, graphDir) {
  return 'digraph G {\n' +
    '  rankdir=' + graphDir + '\n' +
    '  graph [fontname="simhei" splines="polyline"]\n' +
    '  edge  [fontname="simhei" arrowsize="0.6"]\n' +
    '  node  [fontname="simhei" fontsize="9px" shape="note" height="0.1" style="filled" fillcolor="khaki1"]\n' +
    dotEdges +
    "}\n"
}

// 鎶婂紩鎬濈閬撳簭鍒楄浆鎹负妯悜 digraph
function hintPipes2DigraphLR(hintPipeText) {
  var dotEdges = hintPipeText2DotEdges(hintPipeText);
  var digraphLR = dotEdges2Digraph(dotEdges, 'LR');
  return digraphLR;
}

// 鎶婂紩鎬濈閬撳簭鍒楄浆鎹负绾靛悜 digraph
function hintPipes2DigraphTB(hintPipeText) {
  var dotEdges = hintPipeText2DotEdges(hintPipeText);
  var digraphTB = dotEdges2Digraph(dotEdges, 'BT');
  return digraphTB;
}

function dotCodeTidy(dotCodeLines) {
  var patt = /"(%*[0-9]+)"[ \t]+([^;]*)label=([^,]+),([^;]+);/mg;
  var nodeArray = [];
  var result = patt.exec(dotCodeLines);
  while (result != null) {
    var tmpDict = {};
    tmpDict['id'] = result[1];
    tmpDict['label'] = result[3];
    nodeArray.push(tmpDict);
    result = patt.exec(dotCodeLines);
  }
  patt = /"(%*[0-9]+)"([^;]+)label=([^,]+),[ \n\t]*([^;]+);/m;
  result = patt.exec(dotCodeLines);
  while (result != null) {
    var tmpStr = dotCodeLines.replace(patt,
      '"' + result[1] +
      '" [' +
      result[4]
    );
    console.log(result[4]);
    dotCodeLines = tmpStr;
    result = patt.exec(dotCodeLines);
  }
  for (node of nodeArray) {
    var patt = new RegExp(node['id'], 'g');
    var tmpStr = dotCodeLines.replace(patt, node['label']);
    dotCodeLines = tmpStr;
  }
  return dotCodeLines;
}

function instavizDotEdge2HintPipe(str) {
  // var patt = /"*([a-zA-Z0-9涓€-榭嬨悁-皤牃]+)"* -> "*([a-zA-Z0-9涓€-榭嬨悁-皤牃]+)"*;*/g;
  var patt = /"([^->"\t\r\n\[\]]+)" -> "([^->"\t\r\n\[\]]+)";*/g;
  var result = patt.exec(str);
  if (result === null) {
    return '';
  } else {
    return result[1] + '|->|' + result[2];
  }
}

function instavizDigraph2HintPipes(dotLines) {
  dotLineArray = dotLines.split('\n');
  var hintPipes = '';
  for (dotLine of dotLineArray) {
    var hintPipe = instavizDotEdge2HintPipe(dotLine.trim());
    if (hintPipe === '') {
      ;
    } else {
      hintPipes += hintPipe + '\n';
    }
  }
  return hintPipes;
}