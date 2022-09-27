# Cypher Example

一个用于练习flex 和bison的项目，仅涉及词法语法分析，将输入的语句解析成我自己定义的数据结构。

所以核心的print_module是空的，没有做任何实现逻辑[主要还是懒。。。]

如果对cypher做进一步的处理，可以完善print_module函数。甚至增加语法树重写函数等。

A project for Flex-Bison practicing，as a result "print_module" is not supported at this time.

Only parse Cypher query into my slef-define struct tree. No further feature。

if U want to refine it , Just complete your own print_module function.

## How To Run
```shell
$ make
bison -Wno-deprecated -vd parser.y -o parser.c
flex -b -CF -p -p --header-file=scanner.h --outfile=scanner.c scanner.l
%option yylineno entails a performance penalty ONLY on rules that can match newline characters
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat   -c -o parser.o parser.c
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat   -c -o scanner.o scanner.c
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat   -c -o ast.o ast.c
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat   -c -o print.o print.c
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat   -c -o delete.o delete.c
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat   -c -o module.o module.c
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat   -c -o main.o main.c
gcc -g -O0 -U_YYDEBUG -U__YYEMIT -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -Wformat -g -o run parser.o scanner.o ast.o print.o delete.o module.o main.o
```
```shell
$ ./run 
CypherParser=# MATCH (david {name: 'David'})--(otherPerson)-->() WITHE otherPerson, count(*) AS foaf WHERE foaf > 1 RETURN otherPerson.name;


error: location of cypher error was here : 
	MATCH (david {name: 'David'})--(otherPerson)-->() WITHE
	                                                  ↑↑↑↑↑ - Error Here!


```

## 参考资料

《flex 和 bison》

```cypher
CALL db.labels() RETURN count(label) AS numLabels;
CALL db.labels() YIELD * WHERE label = 'User' RETURN count(label) AS numLabels;
CALL db.labels() YIELD asldkjf WHERE label = 'User' RETURN count(label) AS numLabels;
CALL db.propertyKeys() YIELD propertyKey AS prop WHERE label = 'User' RETURN count(label) AS numLabels;
CALL security.createUser('example_username', 'example_password','example_port',1123,'laksjdlfkajsd') RETURN count(label) AS numLabels;
CREATE (a {name: 'Andy'}) RETURN a.name;
CREATE (n:Person {name: 'Andy', title: 'Developer'});
CREATE (n:Person:Swedish);
CREATE p = (andy {name:'Andy'})-[:WORKS_AT]->(neo)<-[:WORKS_AT]-(michael {name: 'Michael'}) RETURN p;
MATCH ()-[r]-() RETURN DISTINCT r.state ORDER BY r.state;
MATCH ()<-[r:LOC_OBJ {state:12}]-(idA {type:2}) RETURN count(r);
MATCH (a {name: 'Andy'}) REMOVE a.age RETURN a.name, a.age;
MATCH (a) WHERE (any(x in a.name where x = 'master') OR any(y in a.value where y in ['postgres', 'nginx'])) AND ('Global' in labels(a) OR 'Meta' in labels(a)) RETURN count(a);
MATCH (a) WHERE a.node_id < 345 OR ((a.node_id > 800 AND 'Process' in labels(a)) OR a.node_id = 983) RETURN count(a);
MATCH (a) WHERE any(lab in labels(a) WHERE lab IN ['Global', 'Meta']) RETURN count(a);
MATCH (a) WHERE any(name in a.name WHERE name = 'uid') RETURN count(a);
MATCH (a)-->(b) WITH b MATCH (c)<--(b) WHERE id(c) < 643 WITH c MATCH ()-[r]-(c) RETURN count(r);
MATCH (a)-->(b)-->(c) WHERE c.node_id < b.node_id WITH c MATCH (d)--(c) WHERE exists(d.ref_count) WITH d MATCH (e)-->(d)<--(f) WHERE f.node_id > e.node_id WITH f MATCH (g)<-[ww]-(f) WHERE ww.state = 5 WITH g MATCH (g)-->(ii)-->(i) RETURN DISTINCT i.node_id ORDER BY i.node_id ASC;
MATCH (a)-->(b)-->(c)-->(d) WHERE id(d) < 123 RETURN count(a) AS cool;
MATCH (a)-[*1..3]->(c:Process) RETURN count(c);
MATCH (a)-[e]-(b) WHERE id(a) IN [100, 200, 300, 400] AND id(b) IN [101, 201, 202, 302, 404] RETURN e.state;
MATCH (a)-[e]->(b)-[f]->(c) WHERE a.type = b.type AND c.pid < b.pid RETURN count(f);
MATCH (a)-[e]->(b:Process) WHERE e.state > 5 WITH b MATCH (c) WHERE (exists(c.pid) AND c.pid < b.pid) WITH c MATCH (c)<--(d:Local) WHERE any(n in d.name WHERE n = '4') RETURN count(d) AS cool_thing;
MATCH (a)-[r:LOC_OBJ]-(b) RETURN b.name, r.state ORDER BY b.node_id ASC LIMIT 15;
MATCH (a)-[z]->(b)-[w]->(c) WHERE a.node_id < b.node_id RETURN w.state, c.type ORDER BY c.node_id ASC;
MATCH (a:Global {name:'postgres'})-->(b:Global) WITH b MATCH (c) WHERE c.sys_time = b.sys_time WITH c MATCH (c)<--(d) RETURN DISTINCT d.node_id ORDER BY d.node_id LIMIT 5;
MATCH (a:Global)-->(b:Local)-->(c:Process)<--(d:Local)<--(b) RETURN count(b);
MATCH (a:Global)-[:LOC_OBJ]->(b) WITH a, count(b) AS num_things WHERE num_things > 2 RETURN a.name ORDER BY a.sys_time DESC;
MATCH (a:Global)-[]->(b) RETURN b.node_id AS conn_id;
MATCH (a:Local)-->(b)<--(c:Process)<--(d) RETURN min(d.node_id);
MATCH (a:Local)-[*4..9]->(b) RETURN DISTINCT b.node_id, b.sys_time AS time_alias ORDER BY b.node_id DESC;
MATCH (a:Meta) RETURN count(distinct a.name);
MATCH (a:Meta) WHERE a.sys_time < 0 OR a.node_id > 845 RETURN count(a);
MATCH (a:Person),(b:Person) WHERE a.name = 'A' AND b.name = 'B' CREATE (a)-[r:RELTYPE]->(b) RETURN type(r);
MATCH (at {name: 'Andy'}), (pn {name: 'Peter'}) SET at = pn RETURN at.name, at.age, at.hungry, pn.name, pn.age;
MATCH (david {name: 'David'})--(otherPerson)-->() WITH otherPerson, count(*) AS foaf WHERE foaf > 1 RETURN otherPerson.name;
MATCH (george {name: 'George'})<--(otherPerson) WITH otherPerson, toUpper(otherPerson.name) AS upperCaseName WHERE upperCaseName = 'C' RETURN otherPerson.name;
MATCH (n {name: 'Andy'}) SET n.age = toString(n.age) RETURN n.name, n.age;
MATCH (n {name: 'Andy'}) SET n.name = 'null' RETURN n.name, n.age;
MATCH (n {name: 'Andy'}) SET n.position = 'Developer', n.surname = 'Taylor';
MATCH (n {name: 'Andy'}) SET n.surname = 'Taylor' RETURN n.name, n.surname;
MATCH (n {name: 'Andy'})-[r:KNOWS]->() DELETE r;
MATCH (n {name: 'George'}) SET n:Swedish RETURN n.name, labels(n) AS labels;
MATCH (n {name: 'Peter'}) REMOVE n:German RETURN n.name, labels(n);
MATCH (n {name:["/var/db/entropy/saved-entropy.7", "/var/db/entropy/saved-entropy.8"]}) RETURN n.node_id ORDER BY n.node_id ASC;
MATCH (n) WHERE 'Global' in labels(n) AND any(name in n.name WHERE name = 'master') OR (exists(n.pid) AND n.status = 2) WITH n MATCH (m:Meta) WHERE m.node_id > n.node_id RETURN DISTINCT n LIMIT 10;
MATCH (n) WHERE 'Local' in labels(n) AND NOT exists(n.pid) WITH n MATCH (m:Global)-[r]->(n) WHERE id(m) > 900 RETURN n.node_id, r.state;
MATCH (n) WHERE 'Meta' in labels(n) OR any(name in n.name WHERE name = 'postgres') WITH n MATCH (m:Process) WHERE id(m) > id(n) WITH m MATCH (p)-->(m) WITH p MATCH (j)<-[:PROC_OBJ_PREV]-(p) WHERE p.sys_time = j.sys_time RETURN count(j);
MATCH (n) WHERE 'Process' in labels(n) WITH n MATCH (m) WHERE m.status = n.status RETURN count(n);
MATCH (n) WHERE exists(n.value) AND exists(n.timestamp) RETURN count(n);
MATCH (n) WHERE id(n) < 3 WITH n MATCH (m) WHERE id(m) < id(n) WITH m MATCH (p) WHERE p.node_id < m.node_id RETURN count(p);
MATCH (n) WHERE id(n) = 345 RETURN n.mono_time, n.sys_time, n.name;
MATCH (n) WHERE id(n) IN [10, 110, 317] AND exists(n.pid) RETURN n.status, n.pid;
MATCH (n)--()--()--()--(n) WHERE exists(n.status) RETURN count(n);
MATCH (n:Actor) RETURN n.name AS name UNION ALL MATCH (n:Movie) RETURN n.title AS name;
MATCH (n:Actor) RETURN n.name AS name UNION MATCH (n:Movie) RETURN n.title AS name;
MATCH (n:Global)-->(m:Local) WHERE n.node_id < m.node_id RETURN count(m);
MATCH (n:Local)<--(m:Global) RETURN m.node_id AS thing, m.type AS ty ORDER BY m.sys_time LIMIT 3;
MATCH (n:Meta)<--(m:Process)-->(p) WHERE n.node_id > m.node_id AND p.node_id <= m.node_id RETURN count(m);
MATCH (n:Person {name: 'UNKNOWN'}) DELETE n;
MATCH (n:Process)<-[e:PROC_OBJ]-(c:Local) WHERE id(n) = 916 AND e.state in [5] RETURN c.name, e.state ORDER BY c.name DESC;
MATCH (p {name: 'Peter'}) SET p += {name: 'Peter Smith', position: 'Entrepreneur'} RETURN p.name, p.age, p.position;
MATCH (p {name: 'Peter'}) SET p += {} RETURN p.name, p.age;
MATCH (p {name: 'Peter'}) SET p = {name: 'Peter Smith', position: 'Entrepreneur'} RETURN p.name, p.age, p.position;
MATCH (p {name: 'Peter'}) SET p = {} RETURN p.name, p.age;
MATCH (person)-[r]->(otherPerson) WITH *, type(r) AS connectionType RETURN person.name, otherPerson.name, connectionType;
MATCH (proc:Process)<-[po:PROC_OBJ]-(loc:Local)<-[lo:LOC_OBJ]-(gl:Global)-->(:Local)-->(proc2:Process) WHERE id(proc) IN [137, 149, 162, 278] RETURN DISTINCT proc2.pid ORDER BY proc2.pid ASC;
MATCH (s)-[e]-(d) WHERE id(s) = 349 AND NOT 'Process' in labels(s) AND NOT 'Global' in labels(d) RETURN d.node_id ORDER BY d.node_id ASC;
MATCH p=shortestPath((f {name:"omega"})-[*1..6]->(t:Meta)) RETURN count(t);
MATCH (charlie:Person {name: 'Charlie Sheen'}), (wallStreet:Movie {title: 'Wall Street'}) MERGE (charlie)-[r:ACTED_IN]->(wallStreet) RETURN charlie.name, type(r), wallStreet.title;
MATCH (oliver:Person {name: 'Oliver Stone'}), (reiner:Person {name: 'Rob Reiner'}) MERGE (oliver)-[:DIRECTED]->(movie:Movie)<-[:ACTED_IN]-(reiner) RETURN movie;
MATCH (person:Person) MERGE (person)-[r:HAS_CHAUFFEUR]->(chauffeur:Chauffeur {name: person.chauffeurName}) RETURN person.name, person.chauffeurName, chauffeur;
MERGE (charlie {name: 'Charlie Sheen', age: 10}) RETURN charlie;
MERGE (michael:Person {name: 'Michael Douglas'}) RETURN michael.name, michael.bornIn;
```
