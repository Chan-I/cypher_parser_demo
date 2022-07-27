```sql
CREATE (a {name: 'Andy'}) RETURN a.name;
CREATE (n:Person {name: 'Andy', title: 'Developer'});
CREATE (n:Person:Swedish);
CREATE p = (andy {name:'Andy'})-[:WORKS_AT]->(neo)<-[:WORKS_AT]-(michael {name: 'Michael'}) RETURN p;
MATCH ()-[r]-() RETURN DISTINCT r.state ORDER BY r.state
MATCH ()<-[r:LOC_OBJ {state:12}]-(idA {type:2}) RETURN count(r)
MATCH (a) WHERE (any(x in a.name where x = 'master') OR any(y in a.value where y in ['postgres', 'nginx'])) AND ('Global' in labels(a) OR 'Meta' in labels(a)) RETURN count(a)
MATCH (a) WHERE a.node_id < 345 OR ((a.node_id > 800 AND 'Process' in labels(a)) OR a.node_id = 983) RETURN count(a)
MATCH (a) WHERE any(lab in labels(a) WHERE lab IN ['Global', 'Meta']) RETURN count(a)
MATCH (a) WHERE any(name in a.name WHERE name = 'uid') RETURN count(a)
MATCH (a)-->(b) WITH b MATCH (c)<--(b) WHERE id(c) < 643 WITH c MATCH ()-[r]-(c) RETURN count(r)
MATCH (a)-->(b)-->(c) WHERE c.node_id < b.node_id WITH c MATCH (d)--(c) WHERE exists(d.ref_count) WITH d MATCH (e)-->(d)<--(f) WHERE f.node_id > e.node_id WITH f MATCH (g)<-[ww]-(f) WHERE ww.state = 5 WITH g MATCH (g)-->(ii)-->(i) RETURN DISTINCT i.node_id ORDER BY i.node_id ASC
MATCH (a)-->(b)-->(c)-->(d) WHERE id(d) < 123 RETURN count(a) AS cool
MATCH (a)-[*1..3]->(c:Process) RETURN count(c)
MATCH (a)-[e]-(b) WHERE id(a) IN [100, 200, 300, 400] AND id(b) IN [101, 201, 202, 302, 404] RETURN e.state
MATCH (a)-[e]->(b)-[f]->(c) WHERE a.type = b.type AND c.pid < b.pid RETURN count(f)
MATCH (a)-[e]->(b:Process) WHERE e.state > 5 WITH b MATCH (c) WHERE (exists(c.pid) AND c.pid < b.pid) WITH c MATCH (c)<--(d:Local) WHERE any(n in d.name WHERE n = '4') RETURN count(d) AS cool_thing
MATCH (a)-[r:LOC_OBJ]-(b) RETURN b.name, r.state ORDER BY b.node_id ASC LIMIT 15
MATCH (a)-[z]->(b)-[w]->(c) WHERE a.node_id < b.node_id RETURN w.state, c.type ORDER BY c.node_id ASC
MATCH (a:Global {name:'postgres'})-->(b:Global) WITH b MATCH (c) WHERE c.sys_time = b.sys_time WITH c MATCH (c)<--(d) RETURN DISTINCT d.node_id ORDER BY d.node_id LIMIT 5
MATCH (a:Global)-->(b:Local)-->(c:Process)<--(d:Local)<--(b) RETURN count(b)
MATCH (a:Global)-[:LOC_OBJ]->(b) WITH a, count(b) AS num_things WHERE num_things > 2 RETURN a.name ORDER BY a.sys_time DESC
MATCH (a:Global)-[]->(b) RETURN b.node_id AS conn_id
MATCH (a:Local)-->(b)<--(c:Process)<--(d) RETURN min(d.node_id)
MATCH (a:Local)-[*4..9]->(b) RETURN DISTINCT b.node_id, b.sys_time AS time_alias ORDER BY b.node_id DESC
MATCH (a:Meta) RETURN count(distinct a.name)
MATCH (a:Meta) WHERE a.sys_time < 0 OR a.node_id > 845 RETURN count(a)
MATCH (a:Person),(b:Person) WHERE a.name = 'A' AND b.name = 'B' CREATE (a)-[r:RELTYPE]->(b) RETURN type(r);
MATCH (at {name: 'Andy'}), (pn {name: 'Peter'}) SET at = pn RETURN at.name, at.age, at.hungry, pn.name, pn.age
MATCH (david {name: 'David'})--(otherPerson)-->() WITH otherPerson, count(*) AS foaf WHERE foaf > 1 RETURN otherPerson.name
MATCH (george {name: 'George'})<--(otherPerson) WITH otherPerson, toUpper(otherPerson.name) AS upperCaseName WHERE upperCaseName = 'C' RETURN otherPerson.name
MATCH (n {name: 'Andy'}) SET n.age = toString(n.age) RETURN n.name, n.age
MATCH (n {name: 'Andy'}) SET n.name = 'null' RETURN n.name, n.age
MATCH (n {name: 'Andy'}) SET n.position = 'Developer', n.surname = 'Taylor'
MATCH (n {name: 'Andy'}) SET n.surname = 'Taylor' RETURN n.name, n.surname
MATCH (n {name: 'Andy'})-[r:KNOWS]->() DELETE r;
MATCH (n {name: 'George'}) SET n:Swedish RETURN n.name, labels(n) AS labels
MATCH (n {name:["/var/db/entropy/saved-entropy.7", "/var/db/entropy/saved-entropy.8"]}) RETURN n.node_id ORDER BY n.node_id ASC
MATCH (n) WHERE 'Global' in labels(n) AND any(name in n.name WHERE name = 'master') OR (exists(n.pid) AND n.status = 2) WITH n MATCH (m:Meta) WHERE m.node_id > n.node_id RETURN DISTINCT n LIMIT 10
MATCH (n) WHERE 'Local' in labels(n) AND NOT exists(n.pid) WITH n MATCH (m:Global)-[r]->(n) WHERE id(m) > 900 RETURN n.node_id, r.state
MATCH (n) WHERE 'Meta' in labels(n) OR any(name in n.name WHERE name = 'postgres') WITH n MATCH (m:Process) WHERE id(m) > id(n) WITH m MATCH (p)-->(m) WITH p MATCH (j)<-[:PROC_OBJ_PREV]-(p) WHERE p.sys_time = j.sys_time RETURN count(j)
MATCH (n) WHERE 'Process' in labels(n) WITH n MATCH (m) WHERE m.status = n.status RETURN count(n)
MATCH (n) WHERE exists(n.value) AND exists(n.timestamp) RETURN count(n)
MATCH (n) WHERE id(n) < 3 WITH n MATCH (m) WHERE id(m) < id(n) WITH m MATCH (p) WHERE p.node_id < m.node_id RETURN count(p)
MATCH (n) WHERE id(n) = 345 RETURN n.mono_time, n.sys_time, n.name
MATCH (n) WHERE id(n) IN [10, 110, 317] AND exists(n.pid) RETURN n.status, n.pid
MATCH (n)--()--()--()--(n) WHERE exists(n.status) RETURN count(n)
MATCH (n:Actor) RETURN n.name AS name UNION ALL MATCH (n:Movie) RETURN n.title AS name;
MATCH (n:Actor) RETURN n.name AS name UNION MATCH (n:Movie) RETURN n.title AS name;
MATCH (n:Global)-->(m:Local) WHERE n.node_id < m.node_id RETURN count(m)
MATCH (n:Local)<--(m:Global) RETURN m.node_id AS thing, m.type AS ty ORDER BY m.sys_time LIMIT 3
MATCH (n:Meta)<--(m:Process)-->(p) WHERE n.node_id > m.node_id AND p.node_id <= m.node_id RETURN count(m)
MATCH (n:Person {name: 'UNKNOWN'}) DELETE n;
MATCH (n:Process)<-[e:PROC_OBJ]-(c:Local) WHERE id(n) = 916 AND e.state in [5] RETURN c.name, e.state ORDER BY c.name DESC
MATCH (p {name: 'Peter'}) SET p += {name: 'Peter Smith', position: 'Entrepreneur'} RETURN p.name, p.age, p.position
MATCH (p {name: 'Peter'}) SET p += {} RETURN p.name, p.age
MATCH (p {name: 'Peter'}) SET p = {name: 'Peter Smith', position: 'Entrepreneur'} RETURN p.name, p.age, p.position
MATCH (p {name: 'Peter'}) SET p = {} RETURN p.name, p.age
MATCH (person)-[r]->(otherPerson) WITH *, type(r) AS connectionType RETURN person.name, otherPerson.name, connectionType;
MATCH (proc:Process)<-[po:PROC_OBJ]-(loc:Local)<-[lo:LOC_OBJ]-(gl:Global)-->(:Local)-->(proc2:Process) WHERE id(proc) IN [137, 149, 162, 278] RETURN DISTINCT proc2.pid ORDER BY proc2.pid ASC
MATCH (s)-[e]-(d) WHERE id(s) = 349 AND NOT 'Process' in labels(s) AND NOT 'Global' in labels(d) RETURN d.node_id ORDER BY d.node_id ASC
MATCH p=shortestPath((f {name:"omega"})-[*1..6]->(t:Meta)) RETURN count(t)
```
