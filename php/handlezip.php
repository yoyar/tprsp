<?php

require_once 'do_post_request.inc.php';

require_once 'include/tprZipEntriesIterator.php';
require_once 'include/tprDocFileFilterIterator.php';

define('TPR_RS_UPLOAD_TMP_DIR', '/tmp/tpr_rszip_uploads');

if( ! is_dir(TPR_RS_UPLOAD_TMP_DIR) ) {
	mkdir(TPR_RS_UPLOAD_TMP_DIR);
}	

define('TPR_POST_URL', '##word2json.url##');

?>
<html>
<head>
	<title>Upload Radio Shows</title>
</head>
<body>

<h1>Upload Radio Shows</h1>

<form enctype="multipart/form-data" action="<?= $_SERVER['PHP_SELF'] ?>" method="POST">
    <!-- MAX_FILE_SIZE must precede the file input field -->
    <input type="hidden" name="MAX_FILE_SIZE" value="268435456" />
    <!-- Name of input element determines name in $_FILES array -->
    Send this file: <input name="userfile" type="file" />
    <input type="submit" value="Send File" />
</form>

<?php

$doc_filenames = array();

if( ! empty($_FILES) ) {

	if( $_FILES['userfile']['error'] != UPLOAD_ERR_OK ) {
		echo "<P>", file_upload_error_message($_FILES['userfile']['error']), "<br>";
		exit();
	}

	var_dump($_FILES);

	if( $_FILES['userfile']['type'] != 'application/zip') {
		echo "<P>Error: File is not a zip file.<br>";
		exit();
	}

	if( $_FILES['userfile']['size'] === 0) {
		echo "<P>Error: File has zero length.<br>";
		exit();
	}

	$zip_filename = tempnam(TPR_RS_UPLOAD_TMP_DIR, 'tpr_rs_zipfile_');

	if( move_uploaded_file($_FILES['userfile']['tmp_name'], $zip_filename)) { 

		$iter = new tprDocFileFilterIterator(new tprZipEntriesIterator($zip_filename));

		foreach( $iter as $key => $docZipEntry) {
			
			$doc_filename = tempnam(TPR_RS_UPLOAD_TMP_DIR, 'tpr_rs_docfile_');
			$doc_filenames[] = $doc_filename;
			$docfp = fopen($doc_filename, 'wb');
			stream_copy_to_stream($docZipEntry->getStream(), $docfp);
			chmod($doc_filename, 0644);

			$json = do_post_request( TPR_POST_URL, file_get_contents( $doc_filename ));

			fclose($docfp);

			var_dump($json);

			$mp3NameIdx = substr($docZipEntry->getNameIndex(), 0, -3) . 'mp3' ;
			$mp3ZipEntry = new tprZipEntry($mp3NameIdx, $docZipEntry->getZipArchive());

			if( ! $mp3ZipEntry->getStream() ) {
				throw new Exception(sprintf(
					"Unable to find expected mp3 file (%s) in zip file (%s). ", 
					$mp3ZipEntry, 
					$_FILES['userfile']['name']
				));
			}

			var_dump($mp3ZipEntry);
		} // end foreach

	} else {
		throw new Exception("Unable to move uploaded file.");
	}

}

function shutdown() {

	global $zip_filename, $doc_filenames;

	unlink($zip_filename);

	foreach($doc_filenames as $fn) unlink($fn);
}
register_shutdown_function('shutdown');


function file_upload_error_message($error_code) {
    switch ($error_code) { 
        case UPLOAD_ERR_INI_SIZE: 
            return 'The uploaded file exceeds the upload_max_filesize directive in php.ini'; 
        case UPLOAD_ERR_FORM_SIZE: 
            return 'The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form'; 
        case UPLOAD_ERR_PARTIAL: 
            return 'The uploaded file was only partially uploaded'; 
        case UPLOAD_ERR_NO_FILE: 
            return 'No file was uploaded'; 
        case UPLOAD_ERR_NO_TMP_DIR: 
            return 'Missing a temporary folder'; 
        case UPLOAD_ERR_CANT_WRITE: 
            return 'Failed to write file to disk'; 
        case UPLOAD_ERR_EXTENSION: 
            return 'File upload stopped by extension'; 
        default: 
            return 'Unknown upload error'; 
    } 
} 

?>

</body>
</html>
