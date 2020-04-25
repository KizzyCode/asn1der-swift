import Foundation


extension TestVectors.Ok {
	static let json = """
	{
	  "length": [
	    {
	      "name": "Simple length (0)",
	      "bytes": [0],
	      "value": 0
	    },
	    {
	      "name": "Simple length (71)",
	      "bytes": [71],
	      "value": 71
	    },
	    {
	      "name": "Simple length (2^7 - 1)",
	      "bytes": [127],
	      "value": 127
	    },

	    {
	      "name": "Complex length (2^7)",
	      "bytes": [129,128],
	      "value": 128
	    },
	    {
	      "name": "Complex length (247)",
	      "bytes": [129,247],
	      "value": 247
	    },
	    {
	      "name": "Complex length (63479)",
	      "bytes": [130,247,247],
	      "value": 63479
	    },
	    {
	      "name": "Complex length (2^16 - 1)",
	      "bytes": [130,255,255],
	      "value": 65535
	    },

	    {
	      "name": "Complex length (2^16)",
	      "bytes": [131,1,0,0],
	      "value": 65536
	    },
	    {
	      "name": "Complex length (16219972)",
	      "bytes": [131,247,127,68],
	      "value": 16219972
	    },
	    {
	      "name": "Complex length (4152312833)",
	      "bytes": [132,247,127,68,1],
	      "value": 4152312833
	    },
	    {
	      "name": "Complex length (2^32 - 1)",
	      "bytes": [132,255,255,255,255],
	      "value": 4294967295
	    },

	    {
	      "name": "Complex length (2^32)",
	      "bytes": [133,1,0,0,0,0],
	      "value": 4294967296
	    },
	    {
	      "name": "Complex length (1062992085431)",
	      "bytes": [133,247,127,68,1,183],
	      "value": 1062992085431
	    },
	    {
	      "name": "Complex length (272125973870533)",
	      "bytes": [134,247,127,68,1,183,197],
	      "value": 272125973870533
	    },
	    {
	      "name": "Complex length (69664249310856483)",
	      "bytes": [135,247,127,68,1,183,197,35],
	      "value": 69664249310856483
	    }
	  ],
	  "object": [
	    {
	      "name": "Null object",
	      "bytes": [5,0],
	      "tag": 5,
	      "value": []
	    },
	    {
	      "name": "Octet string",
	      "bytes": [4,2,55,228],
	      "tag": 4,
	      "value": [55,228]
	    }
	  ],
	  "typed": {
	    "bool": [
	      {
	        "name": "Boolean (false)",
	        "bytes": [1,1,0],
	        "tag": 1,
	        "value": [0],
	        "bool": false
	      },
	      {
	        "name": "Boolean (true)",
	        "bytes": [1,1,255],
	        "tag": 1,
	        "value": [255],
	        "bool": true
	      }
	    ],
	    "integer": [
	      {
	        "name": "Integer (0)",
	        "bytes": [2,1,0],
	        "tag": 2,
	        "value": [0],
	        "uint": 0,
	        "int": 0
	      },
	      {
	        "name": "Integer (7)",
	        "bytes": [2,1,7],
	        "tag": 2,
	        "value": [7],
	        "uint": 7,
	        "int": 7
	      },
	      {
	        "name": "Integer (128)",
	        "bytes": [2,2,0,128],
	        "tag": 2,
	        "value": [0,128],
	        "uint": 128,
	        "int": 128
	      },
	      {
	        "name": "Integer (255)",
	        "bytes": [2,2,0,255],
	        "tag": 2,
	        "value": [0,255],
	        "uint": 255,
	        "int": 255
	      },

	      {
	        "name": "Integer (32759)",
	        "bytes": [2,2,127,247],
	        "tag": 2,
	        "value": [127,247],
	        "uint": 32759,
	        "int": 32759
	      },
	      {
	        "name": "Integer (32933)",
	        "bytes": [2,3,0,128,165],
	        "tag": 2,
	        "value": [0,128,165],
	        "uint": 32933,
	        "int": 32933
	      },
	      {
	        "name": "Integer (65535)",
	        "bytes": [2,3,0,255,255],
	        "tag": 2,
	        "value": [0,255,255],
	        "uint": 65535,
	        "int": 65535
	      },

	      {
	        "name": "Integer (2146947863)",
	        "bytes": [2,4,127,247,211,23],
	        "tag": 2,
	        "value": [127,247,211,23],
	        "uint": 2146947863,
	        "int": 2146947863
	      },
	      {
	        "name": "Integer (2158316671)",
	        "bytes": [2,5,0,128,165,76,127],
	        "tag": 2,
	        "value": [0,128,165,76,127],
	        "uint": 2158316671,
	        "int": 2158316671
	      },
	      {
	        "name": "Integer (4294967295)",
	        "bytes": [2,5,0,255,255,255,255],
	        "tag": 2,
	        "value": [0,255,255,255,255],
	        "uint": 4294967295,
	        "int": 4294967295
	      },

	      {
	        "name": "Integer (9221070861274031910)",
	        "bytes": [2,8,127,247,211,23,206,241,167,38],
	        "tag": 2,
	        "value": [127,247,211,23,206,241,167,38],
	        "uint": 9221070861274031910,
	        "int": 9221070861274031910
	      },
	      {
	        "name": "Integer (9269899520199460000)",
	        "bytes": [2,9,0,128,165,76,127,229,13,132,160],
	        "tag": 2,
	        "value": [0,128,165,76,127,229,13,132,160],
	        "uint": 9269899520199460000
	      },
	      {
	        "name": "Integer (18446744073709551615)",
	        "bytes": [2,9,0,255,255,255,255,255,255,255,255],
	        "tag": 2,
	        "value": [0,255,255,255,255,255,255,255,255],
	        "uint": 18446744073709551615
	      },

	      {
	        "name": "Integer (169853733957366961371495358725388383073)",
	        "bytes": [2,16,127,200,163,165,50,73,204,242,115,179,233,77,225,182,51,97],
	        "tag": 2,
	        "value": [127,200,163,165,50,73,204,242,115,179,233,77,225,182,51,97]
	      },
	      {
	        "name": "Integer (171182961953151877244399165785668727649)",
	        "bytes": [2,17,0,128,200,163,165,50,73,204,242,115,179,233,77,225,182,51,97],
	        "tag": 2,
	        "value": [0,128,200,163,165,50,73,204,242,115,179,233,77,225,182,51,97]
	      },
	      {
	        "name": "Integer (340282366920938463463374607431768211455)",
	        "bytes": [2,17,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255],
	        "tag": 2,
	        "value": [0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255]
	      }
	    ],
	    "null": [
	      {
	        "name": "Null object",
	        "bytes": [5,0],
	        "tag": 5
	      }
	    ],
	    "octet_string": [
	      {
	        "name": "Octet string (empty)",
	        "bytes": [4,0],
	        "tag": 4,
	        "value": []
	      },
	      {
	        "name": "Null object (\\\\x37\\\\xe4)",
	        "bytes": [4,2,55,228],
	        "tag": 4,
	        "value": [55,228]
	      }
	    ],
	    "sequence": [
	      {
	        "name": "Sequence (empty)",
	        "bytes": [48,0],
	        "tag": 48,
	        "value": [],
	        "sequence": []
	      },
	      {
	        "name": "Sequence (one octet string)",
	        "bytes": [48,4,4,2,55,228],
	        "tag": 48,
	        "value": [4,2,55,228],
	        "sequence": [
	          {
	            "name": "Sequence subobject 0 (octet string)",
	            "bytes": [4,2,55,228],
	            "tag": 4,
	            "value": [55,228]
	          }
	        ]
	      },
	      {
	        "name": "Sequence (two octet strings)",
	        "bytes": [48,129,135,4,2,55,228,4,129,128,114,51,14,141,185,27,51,33,92,14,83,63,210,142,52,204,139,9,168,8,135,125,199,216,39,65,147,4,49,189,9,208,214,243,26,104,125,64,96,18,111,12,224,54,10,207,149,222,129,47,164,47,98,246,113,151,224,73,96,59,101,116,143,210,87,227,193,97,29,180,84,164,150,166,179,244,59,39,170,90,235,201,35,88,146,27,39,84,121,230,124,177,121,131,0,91,8,91,133,47,12,47,141,52,71,44,164,112,223,176,163,155,97,51,109,211,145,132,129,151,104,103,84,178,238,87,253,132],
	        "tag": 48,
	        "value": [4,2,55,228,4,129,128,114,51,14,141,185,27,51,33,92,14,83,63,210,142,52,204,139,9,168,8,135,125,199,216,39,65,147,4,49,189,9,208,214,243,26,104,125,64,96,18,111,12,224,54,10,207,149,222,129,47,164,47,98,246,113,151,224,73,96,59,101,116,143,210,87,227,193,97,29,180,84,164,150,166,179,244,59,39,170,90,235,201,35,88,146,27,39,84,121,230,124,177,121,131,0,91,8,91,133,47,12,47,141,52,71,44,164,112,223,176,163,155,97,51,109,211,145,132,129,151,104,103,84,178,238,87,253,132],
	        "sequence": [
	          {
	            "name": "Sequence subobject 0 (octet string)",
	            "bytes": [4,2,55,228],
	            "tag": 4,
	            "value": [55,228]
	          },
	          {
	            "name": "Sequence subobject 1 (octet string)",
	            "bytes": [4,129,128,114,51,14,141,185,27,51,33,92,14,83,63,210,142,52,204,139,9,168,8,135,125,199,216,39,65,147,4,49,189,9,208,214,243,26,104,125,64,96,18,111,12,224,54,10,207,149,222,129,47,164,47,98,246,113,151,224,73,96,59,101,116,143,210,87,227,193,97,29,180,84,164,150,166,179,244,59,39,170,90,235,201,35,88,146,27,39,84,121,230,124,177,121,131,0,91,8,91,133,47,12,47,141,52,71,44,164,112,223,176,163,155,97,51,109,211,145,132,129,151,104,103,84,178,238,87,253,132],
	            "tag": 4,
	            "value": [114,51,14,141,185,27,51,33,92,14,83,63,210,142,52,204,139,9,168,8,135,125,199,216,39,65,147,4,49,189,9,208,214,243,26,104,125,64,96,18,111,12,224,54,10,207,149,222,129,47,164,47,98,246,113,151,224,73,96,59,101,116,143,210,87,227,193,97,29,180,84,164,150,166,179,244,59,39,170,90,235,201,35,88,146,27,39,84,121,230,124,177,121,131,0,91,8,91,133,47,12,47,141,52,71,44,164,112,223,176,163,155,97,51,109,211,145,132,129,151,104,103,84,178,238,87,253,132]
	          }
	        ]
	      }
	    ],
	    "utf8_string": [
	      {
	        "name": "UTF-8 string (\\"\\")",
	        "bytes": [12,0],
	        "tag": 12,
	        "value": [],
	        "utf8str": ""
	      },
	      {
	        "name": "UTF-8 string (\\"Testolope\\")",
	        "bytes": [12,9,84,101,115,116,111,108,111,112,101],
	        "tag": 12,
	        "value": [84,101,115,116,111,108,111,112,101],
	        "utf8str": "Testolope"
	      },
	      {
	        "name": "UTF-8 string (\\"Some UTF-8 Emoji \\uD83D\\uDD96\\uD83C\\uDFFD\\")",
	        "bytes": [12,25,83,111,109,101,32,85,84,70,45,56,32,69,109,111,106,105,32,240,159,150,150,240,159,143,189],
	        "tag": 12,
	        "value": [83,111,109,101,32,85,84,70,45,56,32,69,109,111,106,105,32,240,159,150,150,240,159,143,189],
	        "utf8str": "Some UTF-8 Emoji \\uD83D\\uDD96\\uD83C\\uDFFD"
	      }
	    ]
	  }
	}
	"""
}
