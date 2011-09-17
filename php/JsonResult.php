<?php

class JsonResult {

	private $sections;

	
	
	/**
	 * @param String $filename
	 * 					The filename of the Word document.
	 */
	function __construct($filename) {

		if( ! is_file($filename)) {
			throw new Exception("File does not exist: $filename");
		}
		
		try {
			$result = do_post_request(
				TPR_POST_URL, 
				file_get_contents( $filename )
			);	
		} catch(Exception $e) {
			throw new Exception("Post request failed. Exception: $e");
		}
		
		
		$this->sections = json_decode($result);

		if( null == $this->sections) {
			throw new Exception("Unable to parse json string. ");
		}
	}

	function getSectionIterator() {
		return new SectionIterator($this->sections);
	}

	function getRenderingIterator() {
		return new SectionRenderingIterator(new SectionIterator($this->sections));
	}

	function hasErrors() {

		foreach($this->sections as $section) {
			if( @$section->error) {
				return true;
			}
		}
		return false;
	}
}

class SectionRenderingIterator implements Iterator {

	private $sectionIter;

	function __construct(SectionIterator $si) {
		$this->sectionIter = $si;
	}

	public function current (  ) {

		$renderedString = '';

		$rendererName = $this->key() . 'Renderer';

		if( class_exists($rendererName)) {
			$renderer = new $rendererName($this->sectionIter->current());
			$renderedString = $renderer->render();
		} else {
			$renderedString =  "Error: [$rendererName] Renderer does not exist.";
		}

		return $renderedString;
	}

	public function key (  ) {
		return $this->sectionIter->key();
	}

	public function next (  ) {
		$this->sectionIter->next();
	}

	public function rewind (  ) {
		$this->sectionIter->rewind();
	}

	public function valid (  ) {
		return $this->sectionIter->valid();
	}
}

class SectionIterator implements Iterator {

	private $sections;
	private $idx = 0;

	function __construct($sections) {
		$this->sections = $sections;
	}

	public function current (  ) {
		return $this->sections[$this->idx];
	}

	public function key (  ) {
		$keys = array_keys((array)$this->sections[$this->idx]);
		$sectionName = ucfirst($keys[0]);
		return $sectionName;
	}

	public function next (  ) {
		$this->idx++;
	}

	public function rewind (  ) {
		$this->idx = 0;
	}

	public function valid (  ) {
		return $this->idx < count($this->sections);
	}
}


