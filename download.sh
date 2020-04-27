#!/usr/bin/env bash

# 1 to 906
start_page=1
end_page=906

script_dir=$(pwd)
tmp_dir=$(mktemp -d)

function download_page() {
  pg_num=${1:-1}
  curl "https://www.nfpa.org/NFPA/Custom%20Pages/NFPARequestHandler.ashx?handler=Access&pg=$pg_num" \
    -H 'cookie: free-viewer=codeId=229&code=70&fullCode=NFPA 70®&editionId=5097&edition=2020&path=&folder=7020&title=Free Access to: [[edition]] edition of [[fullCode]]&shortTitle=[[edition]] edition of [[fullCode]]&termsTitle=Accept Terms for: [[edition]] edition of [[fullCode]]&termsShortTitle=Accept Terms&onNfcss=true&sku=NFPA_70&popup=true&close=true&new=true&auth=false&email=false&terms=true&ads=true&backUrl=https://www.nfpa.org/codes-and-standards/all-codes-and-standards/list-of-codes-and-standards/detail?code=70&jump=&page=' \
    --compressed -s -o "$pg_num.png"
}

function download_nec_pages() {


  for (( p=$start_page; p <= $end_page; p++ )); do
    printf "Downloading page $p of $end_page size: "
    download_page "$p"
    du "$pg_num.png"
  done
}

pushd $tmp_dir
  download_nec_pages

  echo "=== Start compiling PDF ==="
  time convert $(seq -f "%g.png" $start_page $end_page) "$script_dir/nec2020.pdf"

  echo "Output PDF located at $script_dir/nec2020.pdf"
popd

read -p "About to delete temp folder $tmp_dir press (Ctrl-c) to cancel, any key to proceed."
rm -rf $tmp_dir
