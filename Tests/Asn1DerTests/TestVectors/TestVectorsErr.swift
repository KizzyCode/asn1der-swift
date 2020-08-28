import Foundation


extension TestVectors.Err {
	static let json = """
	{
	  "length": [
		{
		  "name": "Zero-sized complex length",
		  "bytes": [128],
		  "err": "InvalidData"
		},
		{
		  "name": "Simple length encoded as complex length",
		  "bytes": [129,127],
		  "err": "InvalidData"
		},
		{
		  "name": "Truncated length (expected 1, got 0)",
		  "bytes": [129],
		  "err": "InvalidData"
		},
		{
		  "name": "Truncated length (expected 4, got 3)",
		  "bytes": [132,1,0,0],
		  "err": "InvalidData"
		},
		{
		  "name": "Unsupported length > 2^64 - 1",
		  "bytes": [137,1,0,0,0,0,0,0,0,0],
		  "err": "Unsupported"
		}
	  ],
	  "object": [
		{
		  "name": "Object with invalid length (zero-sized complex length)",
		  "bytes": [0,128],
		  "err": "InvalidData"
		},
		{
		  "name": "Object with invalid length (simple length encoded as complex length)",
		  "bytes": [175,129,127],
		  "err": "InvalidData"
		},
		{
		  "name": "Truncated object (expected 1, got 0)",
		  "bytes": [190,129],
		  "err": "InvalidData"
		},
		{
		  "name": "Truncated object (expected 4, got 3)",
		  "bytes": [215,132,1,0,0],
		  "err": "InvalidData"
		},
		{
		  "name": "Truncated object (expected 9, got 8)",
		  "bytes": [12,9,84,101,115,116,111,108,111,112],
		  "err": "InvalidData"
		},
		{
		  "name": "Truncated object (unsupported length > 2^64 - 1)",
		  "bytes": [119,137,1,0,0,0,0,0,0,0,0],
		  "err": "Unsupported"
		},
		{
		  "name": "Truncated object (unsupported length > 2^64 - 1)",
		  "bytes": [157,247,157,157,157,157,157,157,157,157,157,157,157,157,157,67,157,1,0,0,0,157,157,157,157,157,157,157,157],
		  "err": "InvalidData"
		},
		{
		  "name": "Truncated object with excessive length announcement",
		  "bytes": [5,136,112,0,0,0,0,0,0,0,7,12,5,4],
		  "err": "InvalidData",
		  "err_32bit": "Unsupported"
		}
	  ],
	  "typed": {
		"bool": [
		  {
			"name": "Invalid boolean (invalid tag)",
			"bytes": [2,1,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid boolean (invalid value byte)",
			"bytes": [1,1,1],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid boolean (invalid value length)",
			"bytes": [1,2,0,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Truncated boolean (expected 2, got 1)",
			"bytes": [1,2,0],
			"err": "InvalidData"
		  }
		],
		"integer": [
		  {
			"name": "Invalid integer (invalid tag)",
			"bytes": [3,1,7],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid integer (empty value)",
			"bytes": [2,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid integer (two leading zeroes)",
			"bytes": [2,2,0,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid integer (excessive representation of 127)",
			"bytes": [2,2,0,127],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid integer (excessive representation of -1)",
			"bytes": [2,2,255,255],
			"err": "InvalidData"
		  },
		  {
			"name": "Truncated integer (expected 2, got 1)",
			"bytes": [2,2,128],
			"err": "InvalidData"
		  }
		],
		"null": [
		  {
			"name": "Invalid null object (invalid tag)",
			"bytes": [6,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid null object (not empty)",
			"bytes": [5,1,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Truncated null object (expected 2, got 1)",
			"bytes": [5,2,0],
			"err": "InvalidData"
		  }
		],
		"octet_string": [
		  {
			"name": "Invalid octet string (invalid tag)",
			"bytes": [3,1,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Truncated octet string (expected 1, got 0)",
			"bytes": [4,1],
			"err": "InvalidData"
		  }
		],
		"sequence": [
		  {
			"name": "Invalid sequence (invalid tag)",
			"bytes": [49,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Truncated sequence (truncated subobject; expected 2, got 1)",
			"bytes": [48,3,2,2,128],
			"err": "InvalidData"
		  },
		  {
			"name": "Truncated sequence (expected 5, got 4)",
			"bytes": [48,5,4,2,55,228],
			"err": "InvalidData"
		  }
		],
		"utf8_string": [
		  {
			"name": "Invalid UTF-8 string (invalid tag)",
			"bytes": [13,0],
			"err": "InvalidData"
		  },
		  {
			"name": "Invalid UTF-8 string (non-UTF-8 literal)",
			"bytes": [12,4,240,40,140,40],
			"err": "InvalidData"
		  },
		  {
			"name": "Truncated UTF-8 string (expected 2, got 1)",
			"bytes": [12,2,84],
			"err": "InvalidData"
		  }
		]
	  }
	}
	"""
}
