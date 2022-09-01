#include "module.h"

int main(int argc, char **argv)
{
	module_yy_extra *mod;
	int res;
	char *sql = NULL;

#if USE_PARSE_MODULE
	/**
	 * @brief  There are two APIs.
	 * 			one is new_module_from_stdin()...
	 * 				   parse_module()
	 *
	 * 			the other is raw_parser()
	 *
	 */
	while (1)
	{
		fprintf(stdout, "CypherParser=# ");
		fflush(stdout);
		mod = new_module_from_stdin();
		res = parse_module(mod);
		/**
		 * @brief	the first usage:
		 * 						new_module_from_[stdin/string/file]();
		 * 			   			print_module();
		 *
		 */

		if (!res) // success
		{
			printf("success!\n");
			sql = print_module(mod);
			// printf("%s\n", sql);
		}
		else if (res == 1)
		{
			continue;
		}
		else
			exit(0);
		if (sql)
			free(sql);
		delete_module(mod);
		fprintf(stdout, "\n\n");
		fflush(stdout);
	}
#else
	char *cypher = "MATCH (david {name: 'David'})--(otherPerson)-->() "
				   "WITH otherPerson, count(*) AS foaf WHERE foaf > 1 "
				   "RETURN otherPerson.name ;";

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
#endif
	return res;
}
