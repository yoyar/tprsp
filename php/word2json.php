<?php
/*
 * Read a POSTed TPR Word document and output json
 */
$input = fopen('php://input', 'r');
$tmpname = tempnam('/tmp', 'tpr_worddoc_');
$tmp = fopen($tmpname, 'w');

stream_copy_to_stream($input, $tmp);

chmod($tmpname, 0664);

$command = "antiword -t -w0 $tmpname | iconv -t UTF8 -f UTF8 | tprsp - ";

passthru($command);

fclose($tmp);
fclose($input);

unlink($tmpname);

