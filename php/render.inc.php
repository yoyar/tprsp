<?php

function tprsp_twitterlink($str) {

	$regex = '/(@\w+)/';	

	$result = preg_replace(
		$regex, 
		'<a href="https://twitter.com/$1" rel="nofollow">$1</a>', 
		$str
	);

	return $result;
}

interface SectionRenderer {
	public function render();
}

abstract class BaseRenderer implements SectionRenderer {

	protected $section;

	function __construct($section) {
		$this->section = $section;
	}

	private function preRender() {
		$title = $this->getSectionTitle();
		$class = strtolower($this->getSectionTitle());

		$pre = sprintf(
			'<div class="section %s"> <div>%s:</div> <div class="section-content">',
			$class,
			$title
		);

		return $pre;
	}

	private function postRender() {
		return '</div></div>';
	}

	public function render() {

		$content = $this->getContentArray();

		array_walk(
			$content, 
			function (&$content) {
				$content = trim($content);
				$content = htmlentities($content);
				$content = tprsp_twitterlink($content);
			}
		);


		return 	$this->preRender() .
			vsprintf($this->getFormat(), $content) . 
			$this->postRender();
	}

	abstract protected function getSectionTitle();

	abstract protected function getFormat();

	abstract protected function getContentArray();
	
}

class WeekRenderer extends BaseRenderer {
	
	function __construct($section) {
		parent::__construct($section);
	}

	function getFormat() {
		return '<div>%s</div> <div>%s</div>';
	}

	function getContentArray() {

		$args = array(
			$this->section->week->title,
                        $this->section->week->number
		);

		return $args;
	}

	function getSectionTitle() {
		return 'Week';
	}
}

class FeatureRenderer extends BaseRenderer {
	
	function __construct($section) {
		parent::__construct($section);
	}

	function getContentArray() {
		return array( $this->section->feature->title);
	}

	function getFormat() {
		return '<div>%s</div> ';
	}

	function getSectionTitle() {
		return 'Feature';
	}
}

class AirdateRenderer extends BaseRenderer {
	
	function __construct($section) {
		parent::__construct($section);
	}

	function getContentArray() {
		return array(
			$this->section->airdate->month,
			$this->section->airdate->date,
			$this->section->airdate->year
		);
	}

	function getFormat() {
		return '<div>%s %s, %s</div> ';
	}

	function getSectionTitle() {
		return 'Airdate';
	}
}

class TeaseRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {
		return '<div>%s </div> ';
	}

	function getContentArray() {

		return array($this->findTease($this->section->tease->text));
	}

        function getSectionTitle() {
                return 'Tease';
        }

	private function findTease($line) {

                $teaser = trim($line);

		// remove the last period, and any other periods at the end of the string
		// because later we're going to look for a period in the middle of the string
		// and we don't want to find the last one by mistake.
		while( substr($teaser, -1 ) == '.' ) {
			$teaser = substr($teaser, 0, -1);
			$teaser = trim($teaser);
		}

                if( FALSE !== ($pos = strpos($teaser, '?'))  ) {

			// first sentence ends in a question mark, cut it there.
                        return substr($teaser, 0, $pos) . '?';

                } elseif ( preg_match('/([,])[^,]*([Pp]arent\s+[Rr]eport).*?$/',  $teaser, $m) ) {

			$punct = $m[1];
			',' == $punct && $punct = '.';
			return substr(trim($teaser), 0, - (strlen($m[0]))) . $punct;

                }  elseif( FALSE !== ($pos = strpos(substr($teaser, 0, -1), '.'))) {

                        return substr($teaser, 0, $pos) . '.';  
                }  

		return $line;
        }
}

class IntroRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {
        	return '<div>%s </div> ';
	}

	function getContentArray() {
		return array( $this->findIntro($this->section->intro->text));
	}

        function getSectionTitle() {
                return 'Intro';
        }

	function findIntro($line) {

		// lose the first two sentences. They are usually
		// "Hi.  I'm Joanne Wilson with The Parent Report."
	
		$intro = $line;

		if( ! preg_match(
			'/^([^.]+\.)([^.]+\.)\s+(.*)$/i', 
			$line, 
			$matches
		) ) {
			return $intro;
		}

		// a few sanity checks. 
		if( trim($matches[1]) != 'Hi.' ) return $intro;

		if( ! strstr($matches[2], 'Joanne' ) ) return $intro;
		if( ! strstr($matches[2], 'Wilson' ) ) return $intro;

		return $matches[3];
	}
}

class BridgeRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {
		return '<div>%s </div> ';
	}

	function getContentArray() {
		return array( $this->section->bridge->text);
	}

        function getSectionTitle() {
                return 'Bridge';
        }
}

class ClipRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {
		return '<div>%s </div> ';
	}

	function getContentArray() {
		return array( $this->section->clip->text);
	}

        function getSectionTitle() {
                return 'Clip';
        }
}

class WrapRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {
		return '<div>%s </div> ';
	}

	function getContentArray() {
		return array( $this->section->wrap->text);
	}

        function getSectionTitle() {
                return 'Wrap';
        }
}

class AgesRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {
		return '<div>%s </div> ';
	}

	function getContentArray() {
		return array( join(', ', $this->section->ages->items));
	}

        function getSectionTitle() {
                return 'Ages';
        }

}

class CategoriesRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {
		return '<div>%s </div> ';
	}

	function getContentArray() {

		return array( join(', ', $this->section->categories->items));
	}

        function getSectionTitle() {
                return 'Categories';
        }


}

class ErrorRenderer extends BaseRenderer {

        function __construct($section) {
                parent::__construct($section);
        }

	function getFormat() {

		if( ! @$this->section->lineno ) {
			return '<div>%s</div>';
		}

		return '<div>%s on line: %s</div> ';
	}

	function getContentArray() {

		$error = array();

		array_push($error, $this->section->error);

		if( @$this->section->lineno ) {
			array_push($error, $this->section->lineno);
		}

		return $error;	
	}

        function getSectionTitle() {
                return 'Error';
        }
}

function tprsp_categoriesLookupHash() {
	return array(
			'B' => 'Behaviour',
			'D' => 'Development',
			'SF' =>'Safety',
			'E' => 'Education',
			'N' => 'Nutrition',
			'F' => 'Family Life',
			'H' => 'Health',
			'LS' => 'Limit Setting',
			'KC' => 'Kids Culture',
			'SL' => 'Sleep',
			'F'  => 'Family',
	);
}


function tprsp_agesLookupHash() {
	return array(
		'N' => 'Newborn',
		'I' => 'Infant',
		'IT' => 'Toddler',
		'PS' => 'Preschool',
		'ES' => 'Early School',
		'PT' => 'Preteen',
		'T' => 'Teen',
	);
}
















