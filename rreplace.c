/* replace using posix regular expressions */
#include <stdio.h>
#include <string.h>
#include <regex.h>
#include <stdlib.h>

/**
 * returns the string to use for replacement
 *
 *
 *
 * if the int pointed to by rp_needs_freep is set to 1, the caller must free the return string
 */
static char * replaceSubExpInRp_h1(regmatch_t pmatch[10], const char *buf, char *rp, int * rp_needs_freep){
	char *pos;
	*rp_needs_freep=0;
	for (pos = rp; *pos; pos++)
		if (*pos == '\\' && *(pos + 1) > '0' && *(pos + 1) <= '9') {
			int so, length_of_inserted_string;
			int index = *(pos + 1) - 48;
			so = pmatch [index].rm_so;
			length_of_inserted_string = pmatch [index].rm_eo - so;
			if (so < 0)  {
				goto ERROR;
			}
			if (0 == *rp_needs_freep) {
				*rp_needs_freep =1;
				int read_so_far = pos-rp;

				char * newRp= malloc (strlen (rp) + length_of_inserted_string - (length_of_inserted_string >=2 ? 2 : 0)+1 );
				memmove (newRp, rp, strlen(rp)+1);
				rp = newRp;
				pos = rp + read_so_far;
			}
			else {
				int read_so_far = pos-rp;
				rp = realloc (rp , strlen (rp) + length_of_inserted_string +1 );
				pos = rp+read_so_far;
			}
			memmove (pos + length_of_inserted_string, pos + 2, strlen (pos) - 1);
			memmove (pos, buf + so, length_of_inserted_string);
			pos = pos + length_of_inserted_string - 2;
	}
	return rp;
ERROR:
	if (1 == *rp_needs_freep) {
		free(rp);
	}
	return NULL;

}


/**
 * return s a copy of buf with the matched strings replaced with string in rp
 * 
 *
 *
 * caller must free
 */
char * rreplace (char *buf_orig, regex_t *re, char *rp)
{
	char *pos;
	char * buf = strdup(buf_orig);


	regmatch_t pmatch [10]; /* regoff_t is int so size is int */
	for (pos = buf; !regexec (re, pos, 10, pmatch, 0); ) {
		int newRpNeedFree=0;
		int rp_size;
		char *newRp;
		int n;
		newRp =replaceSubExpInRp_h1(pmatch,pos, rp, &newRpNeedFree);
		if (NULL == newRp) 
			goto error;
	
		rp_size = strlen (newRp );

		n = pmatch [0].rm_eo - pmatch [0].rm_so;
		pos += pmatch [0].rm_so;
		if (rp_size > n) {// we don't need to reallocate it deleting
			int read_so_far = pos-buf;
			buf = realloc (buf , strlen (buf) - n +rp_size+1 );
			pos = buf+read_so_far;
		}
		memmove (pos + rp_size, pos + n, strlen (pos) - n + 1);
		memmove (pos, newRp, rp_size);
		pos += rp_size;
		if (newRpNeedFree) 
			free(newRp);
	}
	return buf;
error:
	free(buf);
	return NULL;
}

int main (int argc, char **argv)
{
	char buf [FILENAME_MAX];
	regex_t re;

	if (argc < 2) return 0;
	if (regcomp (&re, argv [1], 0)) goto err;
	for (; fgets (buf, FILENAME_MAX, stdin);) {
		char * result;
		if (NULL == (result = rreplace (buf, &re,argv [2])))
			goto err;
		printf("%s", result);
		free(result);
	}
	regfree (&re);
	return 0;
err:    regfree (&re);
	return 0;
}
