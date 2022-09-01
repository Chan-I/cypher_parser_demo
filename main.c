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
#if 0
		mod = new_module_from_string("MATCH (david {name: 'David'})--(otherPerson)-->() WITH otherPerson, count(*) AS foaf WHERE foaf > 1 RETURN otherPerson.name;");
		mod = new_module_from_string("MATCH (a)-->(b)-->(c) WHERE c.node_id < b.node_id WITH c MATCH (d)--(c) WHERE exists(d.ref_count) WITH d MATCH (e)-->(d)<--(f) WHERE f.node_id > e.node_id WITH f MATCH (g)<-[ww]-(f) WHERE ww.state = 5 WITH g MATCH (g)-->(ii)-->(i) RETURN DISTINCT i.node_id ORDER BY i.node_id ASC;");
		mod = new_module_from_string("MATCH (a)-[e]->(b:Process) WHERE e.state > 5 WITH b MATCH (c) WHERE (exists(c.pid) AND c.pid < b.pid) WITH c MATCH (c)<--(d:Local) WHERE any(n in d.name WHERE n = '4') RETURN count(d) AS cool_thing;");
		mod = new_module_from_string("MATCH (a:Global)-[:LOC_OBJ]->(b) WITH a, count(b) AS num_things WHERE num_things > 2 RETURN a.name ORDER BY a.sys_time DESC;");
		mod = new_module_from_string("MATCH (n) WHERE id(n) < 3 WITH n MATCH (m) WHERE id(m) < id(n) WITH m MATCH (p) WHERE p.node_id < m.node_id RETURN count(p);");
		mod = new_module_from_string("MATCH (n {name:[\" / var / db / entropy / saved - entropy .7 \", \" / var / db / entropy / saved - entropy .8 \"]}) RETURN n.node_id ORDER BY n.node_id ASC;");
		mod = new_module_from_string("MATCH (a)-->(b)-->(c) WHERE c.node_id < b.node_id WITH c MATCH (d)--(c) WHERE exists(d.ref_count) WITH d MATCH (e)-->(d)<--(f) WHERE f.node_id > e.node_id WITH f MATCH (g)<-[ww]-(f) WHERE ww.state = 5 WITH g MATCH (g)-->(ii)-->(i) RETURN DISTINCT i.node_id ORDER BY i.node_id ASC;");
#endif
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
