# 入力: latency(ms) status route
{
  lat=$1+0; st=$2+0; r=$3;
  if (st==503 && r=="/chat") {
    cls = (lat<=150) ? "fast_fail" : (lat>=2900 && lat<=3100 ? "near_timeout" : "other");
    counts[cls]++
  }
}
END {
  printf("{\"ts\": %d, \"route\": \"/chat\", \"class_counts\": {", systime());
  first=1;
  for (k in counts) {
    if (!first) printf(", ");
    printf("\"%s\": %d", k, counts[k]);
    first=0;
  }
  if (first) printf("\"none\":0");
  printf("}}\n");
}
