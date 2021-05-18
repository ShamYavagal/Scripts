var Url = 'http://originppv4.shonoc.com/live/shoeast/showtime.isml/.mpd',
http,
http1,
xml,
xmlDoc,
video_aset,
segtemplate,
timescale,
video_timescale,
pubtime,
timeshift,
segtimeline,
s_tag,
each_s_tag,
si_duration,
si_duration_seconds,
si_starttime,
si_duration_int,
accumulated_t = 0,
oldest_t = 0,
newest_t = 0,
last_t = 0,
newest_t_unix,
newest_t_unix_2deci,
Time,
secs_since_epoch,
secs_since_epoch_2deci,
time_diff,
days,
hours,
minutes,
seconds,
result,
s_t,
t_i,
d_i,
r_i;
http = new XMLHttpRequest();
http.onreadystatechange = function () {
  if (this.readyState == 4 && this.status == 200) {
    xmlDoc = this.responseXML;
  }
  else if (this.readyState == 4 && this.status == 304) {
    xmlDoc = this.responseXML;
  }
  else if (this.status != 200) {
    console.log('Problem getting the Manifest, Http Response Code: ' + this.status);
  }
  xml = xmlDoc.getElementsByTagName('MPD') [0];
  pubtime = xml.getAttribute('publishTime')
  timeshift = xml.getAttribute('timeShiftBufferDepth')
  video_timescale = xmlDoc.getElementsByTagName('AdaptationSet')
  for (i = 0; i < video_timescale.length; i++) {
    if (video_timescale[i].getAttribute('contentType') == 'video') {
      video_aset = video_timescale[i];
    }
  }
  segtemplate = video_aset.getElementsByTagName('SegmentTemplate') [0];
  timescale = segtemplate.getAttribute('timescale');
  segtimeline = segtemplate.getElementsByTagName('SegmentTimeline') [0];
  s_tag = segtimeline.getElementsByTagName('S');
  for (each_s_tag = 0; each_s_tag < s_tag.length; each_s_tag++)
  {
    t_i = s_tag[each_s_tag].getAttribute('t');
    d_i = s_tag[each_s_tag].getAttribute('d');
    r_i = s_tag[each_s_tag].getAttribute('r');
    si_duration = r_i * d_i;
    si_duration_seconds = si_duration / timescale;
    si_duration_int = si_duration_seconds.toFixed(0)
    if (t_i) {
      last_t = t_i;
      accumulated_t = t_i;
    }
    si_starttime = accumulated_t;
    accumulated_t = eval(accumulated_t) + eval(si_duration);
    if (newest_t == 0) {
      newest_t = accumulated_t;
    }
    else if (newest_t < accumulated_t) {
      newest_t = accumulated_t;
    }
  }
  newest_t_unix = newest_t / timescale;
  newest_t_unix_2deci = newest_t_unix.toFixed(2);
  secs_since_epoch = new Date().getTime() / 1000;
  secs_since_epoch_2deci = secs_since_epoch.toFixed(2);
  time_diff = Math.abs(eval(secs_since_epoch_2deci) - eval(newest_t_unix_2deci)).toFixed(1);
  seconds = parseInt(time_diff, 10);
  days = Math.floor(seconds / (3600 * 24));
  seconds = seconds - days * 3600 * 24;
  hours = Math.floor(seconds / 3600);
  seconds = seconds - hours * 3600;
  minutes = Math.floor(seconds / 60);
  seconds = seconds - minutes * 60;
  result = 'Difference Between TimeStamp & Current Time: ' + days + ' Days, ' + hours + ' Hours, ' + minutes + ' Minutes, ' + seconds + ' Seconds';
  if (seconds < 15) {
    html_time = "Time-In-Sync";
  }
  else {
    html_time = "Time-Not-In-Sync";
  }
  document.getElementById("time1").innerHTML = html_time;
};
http.open('GET', Url, true);
http.timeout = 2000;
http.ontimeout = function (e) {
  console.error('Connection Timeout')
}
http.send();

//console.log('Exact Seconds: ' + time_diff);
//console.log(pubtime);
//console.log(timeshift);
//console.log(timescale);
//console.log(segtimeline);
//console.log(s_tag);
//console.log(t_i);
//console.log(d_i);
//console.log(r_i);
//console.log(si_duration);
//console.log(si_duration_seconds);
//console.log(si_duration_int);
//console.log(accumulated_t);
//console.log(newest_t_unix);
//console.log(newest_t_unix_2deci);
//console.log(secs_since_epoch_2deci);
//console.log(secs_since_epoch);
//console.log(video_timescale);
//console.log(video_aset);
//console.log(segtemplate);
