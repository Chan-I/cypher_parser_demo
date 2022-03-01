#include "module.h"

int
main(int argc, char **argv) 
{
	module *mod;
	int res;
	char *sql;
	extern int yydebug ;
	mod = new_module_from_string("MATCH (a:Global {name:'1234567'})-[:tree {tec:'766'}]->(b:Global)  WHERE id(b) IN [101, 201, 202, 302, 404] and a.name=true and a.wq > 2 return  a.id , b.name as bcol, count(distinct c.name), min( d.guid) order by e.no limit 100;");
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
