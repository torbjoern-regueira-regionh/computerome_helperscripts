module load tools
module load firefox/149.0

cd /home/projects/reg_00044/apps/ribbon/ribbon_splitthreader
python3 -m http.server &
firefox http://localhost:8000 &

