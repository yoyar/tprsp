<?php

class tprZipEntry {
	
	private $nameIdx;
	private $zipArchive;
		
	//const COMMAND = 'catdoc -x -u -w -';
	//const COMMAND = 'antiword -t -w0 - ';
	
	public function __construct($nameIdx, ZipArchive &$za) {
		
		$this->nameIdx = $nameIdx;
		$this->zipArchive = $za;
	}
	
	public function getNameIndex() {
		return $this->nameIdx;
	}
	
	public function getZipArchive() {
		return $this->zipArchive;
	}
	
	public function getStream() {
		return $this->zipArchive->getStream($this->nameIdx);
	}
	
	public function __toString() {
		return $this->nameIdx;
	}
	
	public function getDocFileAsPlainText() {

		throw new Exception("This method will be removed (getDocFileAsPlainText())");
		
		$streamHandle = $this->getStream();
	
		$tmpname = tempnam('/tmp', 'tpr_rsdocfile_');
		
		$dest = fopen($tmpname, 'w');
		
		stream_copy_to_stream($streamHandle, $dest);
		
		fclose($dest);
		
		$command = "antiword -t -w0 $tmpname"; 
		
		$output = `$command`;
				
		return $output;
		
//		$pipeSpec = array(
//			0  => array('pipe', 'r'), // stdin
//			1 => array('pipe', 'w'), // stdout
//			2 => array('pipe', 'w') // stderr
//		);
//		
//		$process = proc_open(self::COMMAND, $pipeSpec, $pipes);
//		
//		if( ! is_resource($process)) {
//			throw new Exception('Unable to create process: ' . self::COMMAND);	
//		}
//		
//		while( ! feof($streamHandle)) {
//			fwrite($pipes[0], fread($streamHandle, 8192));
//		}
//		fclose($streamHandle); // close the .doc file
//		fclose($pipes[0]); // close stdin
//		
//		$antiwordOutput = '';
//		while( ! feof($pipes[1])) {
//			$antiwordOutput .= fread($pipes[1], 1024);
//		}
//
//		$antiwordOutput = trim($antiwordOutput);
//
//
//		$stderr = fread($pipes[2], 1024);
//
//		
//		fclose($pipes[1]); // close stdout
//		fclose($pipes[2]); // close stderr
//		
//		$return_value = proc_close($process);	
//		
//		if( $return_value != 0 ) {
//			throw new Exception(
//				self::COMMAND . " Command failed with return value $return_value "
//				. "and error: $stderr"
//			);
//		}
//
//		//$antiwordOutput = str_replace('é', '&eacute;', $antiwordOutput);
//
//		//drupal_set_message($antiwordOutput);
//		
//		return $antiwordOutput;
	}
}

