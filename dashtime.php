<?php

//header("Content-Type: text/xml; charset=utf-8");
function get_mpd($path) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,$path);
    curl_setopt($ch, CURLOPT_FAILONERROR,1);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION,1);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
    curl_setopt($ch, CURLOPT_TIMEOUT, 20);
    $mpd_xml = curl_exec($ch);
    curl_close($ch);
    return $mpd_xml;
}

$manifest = get_mpd('http://54.166.166.57/live/ppv1/showtime.isml/.mpd');
//echo $manifest;
//echo gettype($manifest);

$xmlDoc = new DOMDocument();
$xmlDoc->preserveWhiteSpace = FALSE;
$xmlDoc->loadXML($manifest);
$mpd = $xmlDoc->getElementsByTagName('MPD')->item(0);
//$mpd = $xmlDoc->getElementsByTagName('MPD');

$pubtime =  $mpd->getAttribute('publishTime');
$timeshift = $mpd->getAttribute('timeShiftBufferDepth');
//echo gettype($mpd);

$video_timescale = $xmlDoc->getElementsByTagName('AdaptationSet');
//echo $video_timescale->length;
//echo gettype($video_timescale);

for ($x = 0; $x < $video_timescale->length; $x++) {
    if ($video_timescale[$x]->getAttribute('contentType') == 'video') {
        $video_aset = $video_timescale[$x];
    }
}

$segtemplate = $video_aset->getElementsByTagName('SegmentTemplate')->item(0);
$timescale = $segtemplate->getAttribute('timescale');
//echo $segtemplate->getAttribute('timescale');
//echo $video_aset->getAttribute('contentType');

$segtimeline = $segtemplate->getElementsByTagName('SegmentTimeline')->item(0);
//echo $segtimeline->tagName;
$s_tag = $segtimeline->getElementsByTagName('S');


$newest_t = 0;
//echo $s_tag->length;
for ($each_s_tag = 0; $each_s_tag < $s_tag->length; $each_s_tag++) {
    $t_i = $s_tag[$each_s_tag]->getAttribute('t');
    $d_i = $s_tag[$each_s_tag]->getAttribute('d');
    $r_i = $s_tag[$each_s_tag]->getAttribute('r');
    $si_duration = $r_i * $d_i;
    $si_duration_seconds = $si_duration / $timescale;
    $si_duration_int = intval($si_duration_seconds);

    if ($t_i) {
      $last_t = $t_i;
      $accumulated_t = $t_i;
    }
    $si_starttime = $accumulated_t;
    $accumulated_t = $accumulated_t + $si_duration;

    if ($newest_t == 0) {
        $newest_t = $accumulated_t;
    }
    elseif ($newest_t < $accumulated_t) {
      $newest_t = $accumulated_t;
    }
}

$newest_t_unix = intval($newest_t / $timescale);

$secs_since_epoch =  time();

$time_diff = abs($secs_since_epoch - $newest_t_unix);

echo $time_diff;
echo "\n";

/*
if ($time_diff > 15) {
    echo "TimeNotInSync";
}
else {
  echo "TimeInSync";
}
*/
//echo "\n";
//echo $time_diff;
//echo gettype($si_duration_seconds);
//echo gettype($si_duration);
//echo "\n";
//echo $si_duration;
//echo $pubtime;
//echo $timeshift;
//echo $mpd;
//echo $mpd->tagName;
//echo $mpd->textContent;
//var_dump($mpd);

?>
