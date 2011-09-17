<?php 

class tprDocFileFilterIterator extends FilterIterator {
	
	public function __construct(Iterator $iter) {
		parent::__construct($iter);	
	}

	public function accept() {

		$currentNameIndex = $this->getInnerIterator()->current()->getNameIndex();

		// ignore files in the __MACOSX dir
		if( strstr($currentNameIndex, '__MACOS') 
			||
			strstr($currentNameIndex, '__MACOSX')
		) {
			return false;
		}

		// ignore file named 'All.doc' - it just contains all of the scripts in one
		// file and that isn't useful for what we're doing.
		if( substr($currentNameIndex, -7, 7) == 'All.doc') {
			return false;
		}

		$last4Chars = substr($currentNameIndex, -4, 4);

		// return only the .doc files. 
		return strtolower($last4Chars) == '.doc';
	}
}
