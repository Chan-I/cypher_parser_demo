#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

#include "ast.h"

List *
lcons(void *datum, List *list)
{
	assert(IsPointerList(list));

	if (list == NIL)
		list = new_list(T_List);
	else
		new_head_cell(list);

	lfirst(list->head) = datum;
	return list;
}

static List *
new_list(NodeTag type)
{
	List	   *new_list;
	ListCell   *new_head;

	new_head = (ListCell *) malloc(sizeof(*new_head));
	new_head->next = NULL;
	/* new_head->data is left undefined! */

	new_list = (List *) malloc(sizeof(*new_list));
	new_list->type = type;
	new_list->length = 1;
	new_list->head = new_head;
	new_list->tail = new_head;

	return new_list;
}

static void
new_head_cell(List *list)
{
	ListCell   *new_head;

	new_head = (ListCell *) malloc(sizeof(*new_head));
	new_head->next = list->head;

	list->head = new_head;
	list->length++;
}

static void
new_tail_cell(List *list)
{
	ListCell   *new_tail;

	new_tail = (ListCell *) malloc(sizeof(*new_tail));
	new_tail->next = NULL;

	list->tail->next = new_tail;
	list->tail = new_tail;
	list->length++;
}

List *
lappend(List *list, void *datum)
{
	assert(IsPointerList(list));

	if (list == NIL)
		list = new_list(T_List);
	else
		new_tail_cell(list);

	lfirst(list->tail) = datum;
	return list;
}

static void
check_list_invariants(const List *list)
{
	if (list == NIL)
		return;

	assert(list->length > 0);
	assert(list->head != NULL);
	assert(list->tail != NULL);

	if (list->length == 1)
		assert(list->head == list->tail);
	if (list->length == 2)
		assert(list->head->next == list->tail);
	assert(list->tail->next == NULL);
}

static void
list_free_private(List *list, bool deep)
{
	ListCell   *cell;

	check_list_invariants(list);

	cell = list_head(list);
	while (cell != NULL)
	{
		ListCell   *tmp = cell;

		cell = lnext(cell);
		if (deep)
			free(lfirst(tmp));
		free(tmp);
	}

	if (list)
		free(list);
}


void
list_free(List *list)
{
	list_free_private(list, true);
}