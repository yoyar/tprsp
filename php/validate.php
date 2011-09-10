<?php

require_once 'do_post_request.inc.php';
require_once 'render.inc.php';

define('TPR_POST_URL', 'http://localhost:88/tprsp/php/word2json.php');

?>
<html>

<head>
        <title>Validate a Radio Script</title>
<style>

body {
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:12px;
}

.section {
	border: solid 1px;
	margin-bottom: 10px;
	padding: 10px;
}

.section-content {
	margin-left:20px;
	margin-right:20px;
	margin-top:10px;
}

.error {
	color: red;
}

.errors-found {
	margin-bottom:10px;
	font-weight:bold;
}

</style>
</head>

<body>
Validate a Radio Script  

<form enctype="multipart/form-data" action="<?= $_SERVER['PHP_SELF'] ?>" method="POST">
    <!-- MAX_FILE_SIZE must precede the file input field -->
    <input type="hidden" name="MAX_FILE_SIZE" value="30000000" />
    <!-- Name of input element determines name in $_FILES array -->
    Send this file: <input name="userfile" type="file" />
    <input type="submit" value="Send File" />
</form>

<?php

define('TPR_RS_UPLOADS', '/tmp/tpr_rs_uploads');

if( ! is_dir(TPR_RS_UPLOADS) ) {
	mkdir(TPR_RS_UPLOADS);
}

if( !empty($_FILES) ) {

	$filename = tempnam(TPR_RS_UPLOADS, 'tpr_rs_zip_');

	if( $_FILES['userfile']['size'] === 0 ) {
		echo "<P>Error: no file was uploaded. <br>";
		exit();
	}

	if ( $_FILES['userfile']['type'] != 'application/msword' ) {
		echo "<p>Error: uploaded file is not a MS Word file.<br>";
		exit();
	}

	if( move_uploaded_file($_FILES['userfile']['tmp_name'], $filename)) {

		$result = do_post_request(
			TPR_POST_URL, 
			file_get_contents( $filename )
		);

		//`cp $filename /tmp/uploaded.test.ms.word.file.doc`;

		$sections = json_decode($result);

		if( null == $sections) {
			echo "<P>Unable to parse document. Is it a TPR script document?<br>";
			exit();
		}


		$errorsFlag = false;

		array_walk(
			&$sections,
			function(&$section) {
				global $errorsFlag;
				if( @$section->error) $errorsFlag = true; 
			}
		);

		if( $errorsFlag ) echo '<div class="error errors-found">Errors found in script. '.
					'Please examine the output below.</div>';

		
		
		foreach($sections as $section ) {

			$keys = array_keys((array)$section);
			$sectionName = ucfirst($keys[0]);

			$rendererName = $sectionName . 'Renderer'; 

			if( class_exists($rendererName)) {
				$renderer = new $rendererName($section);
				echo $renderer->render();
			} else {
				echo "<P>[$rendererName] Renderer does not exist.";
				var_dump($section);
			}
		}

		
	} else {
		echo "Invalid file";
	}
}

?>

</body>

</html>

