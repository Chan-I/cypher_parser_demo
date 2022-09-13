#include "module.h"

int main(int argc, char **argv)
{
	module_yy_extra *mod;
	char *sql = NULL;

#if 0

	/*
	 * Correct query with comment
	 *  	Mainly Testing for normally Cypher Parsing ...
	 *
	 */

	char *cypher = "MATCH /*asldkjflaskdjfls */ (david {name: 'David'})--(otherPerson)-->() \n"
				   "WITH otherPerson, count(*) AS foaf WHERE foaf > 1 "
				   "RETURN otherPerson.name;";
#else

	/*
	 * Incorrect query
	 *  	Mainly Testing for Error Message Reporting ...
	 *
	 */

	char *cypher = "MATCH \n"
				   "(david {name: 'David'})--(otherPerson)-->() "
				   "WITHE otherPerson, count(*) AS foaf WHERE foaf > 1 "
				   "RETURN otherPerson.name;";
#endif

	fprintf(stdout, "CypherParser=# %s\n\n", cypher);
	fflush(stdout);

	mod = raw_parser(cypher);

	if (!mod->yyresult || mod->yyresult == 2) // success or no query
		printf("success!\n");
	else
		exit(0);

	sql = print_module(mod);
	delete_module(mod);

	if (sql)
		free(sql);

	return 0;
}
