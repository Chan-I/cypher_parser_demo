#include "module.h"

int main(int argc, char **argv)
{
	module_yy_extra *mod;
	int res;
	char *sql = NULL;

	char *cypher = "MATCH (david {name: 'David'})--(otherPerson)-->() "
				   "WITH otherPerson, count(*) AS foaf WHERE foaf > 1 "
				   "RETURN otherPerson.name V;";

	fprintf(stdout, "CypherParser=# %s\n\n", cypher);
	fflush(stdout);

	/**
	 * @brief	the second usage:
	 * 			   			raw_parser();
	 *
	 */

	mod = raw_parser(cypher);

	if (!mod->yyresult) // success
	{
		printf("success!\n");
		sql = print_module(mod);
		// printf("%s\n", sql);
	}
	else
		exit(0);
	if (sql)
		free(sql);
	delete_module(mod);

	fprintf(stdout, "\n\n");
	fflush(stdout);
	return res;
}
