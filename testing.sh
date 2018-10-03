for entry in "sinput"/*
do
    echo "$entry"
    mipl_parser < "$entry"
    echo " "
done