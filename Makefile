CFLAGS =  -ggdb -Wall

all: rreplace


test: all
	cat /var/log/messages |head -5 | valgrind --leak-check=full  ./rreplace "\(n\(a\)r\(tor\)\)" "fsaf \3 \2 \"\1\""

test_del: all
	cat /var/log/messages |head -5 | valgrind --leak-check=full  ./rreplace "\(n\(a\)r\(tor\)\)" ""

test_big: all
	cat /var/log/messages |head -5 | valgrind --leak-check=full  ./rreplace "\(n\(a\)r\(tor\)\)" "asfsdfasfhaskjdfhksadfjhasdlfkahsdfjkashdfkjasdhfkjasdhfjaksdfhaksjdfhsakjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhasdfklajsdf"

test_double_sub: all
	echo "348902345890234 nartor 34234 nartor sdfasd f"| valgrind --leak-check=full  ./rreplace "\(n\(a\)r\(tor\)\)" "[\3 \2] "

test_sub_error: all
	echo "348902345890234 nartor 34234 nartor sdfasd f"| valgrind --leak-check=full  ./rreplace "\(n\(a\)r\(tor\)\)" "[\3 \2 \5] "

test_sub_error1: all
	echo "348902345890234 nartor 34234 nartor sdfasd f"| valgrind --leak-check=full  ./rreplace "\(\)nartor" "[\1] "

test_all: test_double_sub test_del test_big test

make_profile:
	lcov --directory . --zerocounters
	gcc -fprofile-arcs -ftest-coverage -o rreplace_profile rreplace.c
	cat /var/log/messages |head -5 | ./rreplace_profile "\(n\(a\)r\(tor\)\)" "fsaf \3 \2 \"\1\"" > /dev/null
	cat /var/log/messages |head -5 | ./rreplace_profile "\(n\(a\)r\(tor\)\)" ""> /dev/null
	cat /var/log/messages |head -5 | ./rreplace_profile  "\(n\(a\)r\(tor\)\)" "asfsdfasfhaskjdfhksadfjhasdlfkahsdfjkashdfkjasdhfkjasdhfjaksdfhaksjdfhsakjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhasdfklajsdf"> /dev/null
	cat /var/log/messages |head -5 | ./rreplace_profile  "nartor" "\1asfsdfasfhaskjdfhksadfjhasdlfkahsdfjkashdfkjasdhfkjasdhfjaksdfhaksjdfhsakjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhaskjdfhasdfklajsdf"> /dev/null
	cat /var/log/messages |head -1 | ./rreplace_profile  > /dev/null
	cat /var/log/messages |head -1 |./rreplace_profile asfsf > /dev/null
	echo "348902345890234 nartor 34234 nartor sdfasd f"|  ./rreplace_profile "\(n\(a\)r\(tor\)\)" "[\3 \2] "
	echo "348902345890234 nartor 34234 nartor sdfasd f"|  ./rreplace_profile "\(n\(a\)r\(tor\)\)" "[\. \f] "
	echo "348902345890234 nartor 34234 nartor sdfasd f"|  ./rreplace_profile "nartor" "bla "
	echo "348902345890234 nartor 34234 nartor sdfasd f"|  ./rreplace_profile "nart[or" "bla "
	echo "348902345890234 nartor 34234 nartor sdfasd f"|  ./rreplace_profile "\(\)nartor" "[\1] "
	echo "348902345890234 nartor 34234 nartor sdfasd f"|  ./rreplace_profile "\(\)nartor" "[\1 \2] "
	gcov rreplace.c

make_lcov: make_profile
	lcov --directory . --capture --output-file app.info
	genhtml -o html app.info 

profile: make_profile test_all

clean:
	rm -f rreplace rreplace_profile 
	rm -rf html
	rm -f *.gc*
	rm -f app.info
