#include "module.h"

int
main(int argc, char **argv) 
{
	module *mod;
	int i, res;
	char *sql;
	extern int yydebug ;
	mod = new_module_from_string("MATCH (a:Global {name:'postgres'})-->(b:Global)  WHERE any(name in n.name WHERE name = 'master') AND id(b) IN [101, 201, 202, 302, 404]  return  a.id , b.name as bcol, count(distinct c.name), min( d.guid) order by e.no limit 100;");
	res = parse_module(mod);
	
	if(!res) // success
	{
		sql = print_module(mod);
  		printf("%s\n",sql);
	}
	if (sql)
		free(sql);
	delete_module(mod);
	return res;


}
