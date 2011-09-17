<?php

require_once 'tprZipEntry.php';

class tprZipEntriesIterator implements Iterator {

	private $index = 0;
	private $z;
	
	public function __construct($zipFilename) {

		$this->z = new ZipArchive();

		if( $this->z->open($zipFilename) !== true ) {
			throw new Exception("Unable to open zip archive: $zipFilename");
		}
	}

	public function __destruct() {
		$this->z->close();
	}

	public function valid() {
		return $this->index < $this->z->numFiles; 
	}

	public function next() {
		++$this->index;
	}

	public function key() {
		return $this->index;
	}

	public function current() {
		
		//echo 'name index: ', $this->z->getNameIndex($this->index), "\n";
		
		return new tprZipEntry(
			$this->z->getNameIndex($this->index),
			$this->z
		);
	}

	public function rewind() {
		$this->index = 0;
	}
}















