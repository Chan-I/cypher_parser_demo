#include "module.h"

int main(int argc, char **argv)
{
#if 0
	/*
	 * Correct query with comment
	 *  	Mainly Testing for normally Cypher Parsing ...
	 *
	 */

	char *cypher = "MATCH /*asldkjflaskdjfls */ "
				   "(david {name: 'David'})--(otherPerson)-->() \n"
				   "WITH otherPerson, count(*) AS foaf WHERE foaf > 1 "
				   "RETURN otherPerson.name;";
#else
	/*
	 * Incorrect query
	 *  	Mainly Testing for Error Message Reporting ...
	 *
	 */

	char *cypher = "MATCH "
				   "(david {name: 'David'})--(otherPerson)-->() "
				   "WITHE otherPerson, count(*) AS foaf WHERE foaf > 1 "
				   "RETURN otherPerson.name;";
#endif

	module_yy_extra *mod;
	char *sql = NULL;

	fprintf(stdout, "CypherParser=# %s\n\n", cypher);
	fflush(stdout);

	mod = raw_parser(cypher);

	/**
	 * CPR_SUCCESSED(mod)
	 * 		  return 1 if raw_parser success !
	 * 		  return 0 if raw_parser fail !
	 *
	 */
	if (!CPR_SUCCESSED(mod))
		exit(0);

	printf("Cypher 2 SQL:\n");

	/**
	 *
	 *  The main content of this function [print_module], [delete_module]
	 * 	is null. Because this project is a simple Demo for
	 *  Flex-Bison practicing.
	 *
	 *  Attention:
	 *    So, This "Cypher 2 SQL" feature is not supported at this time.
	 *
	 */
	sql = print_module(mod);
	delete_module(mod);

	if (sql)
		free(sql);

	return 0;
}
