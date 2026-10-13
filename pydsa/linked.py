from math import inf
from typing import Optional, Tuple

from .nodes import ListNode


def build_linked_list(vals):
    dummy = ListNode()
    it = dummy
    for v in vals:
        it.next = ListNode(v)
        it = it.next
    return dummy.next


def print_linked_list(head):
    seen = set()
    while head:
        if id(head) in seen:
            print(f" -> [{head.val}] (cycle)")
            break
        seen.add(id(head))
        print(head.val, end=(" -> " if head.next else ""))
        head = head.next
    print("")


def get_list_values(head):
    seen = set()
    ret = []
    while head:
        if id(head) in seen:
            break
        seen.add(id(head))
        ret.append(head.val)
        head = head.next
    return ret


def draw_linked_list(head):
    if not head:
        print("Empty linked list")
        return
    from PrettyPrint import PrettyPrintLinkedList  # see tree_utils

    pt = PrettyPrintLinkedList(
        lambda x: x.val,
        lambda x: x.next,
        lambda x: None,
        orientation=PrettyPrintLinkedList.Horizontal,
        color="\x1b[44m",
    )
    pt(head)


def linked_list_reverse_k(
    h: Optional[ListNode], k: float = inf
) -> Tuple[Optional[ListNode], Optional[ListNode]]:
    """Reverse the first k nodes of the list at h, in place.

    Returns the new head and the new tail. The tail is the node that was h,
    and its next is the first node that was not reversed. With k left out,
    or a list shorter than k, the whole list is reversed and the tail's next
    is None.

    >>> head, tail = linked_list_reverse_k(build_linked_list([1, 2, 3, 4, 5]), 3)
    >>> get_list_values(head), tail.val
    ([3, 2, 1, 4, 5], 1)
    """
    d = ListNode()
    t = h
    while h and k > 0:
        d.next, h.next, h = h, d.next, h.next
        k -= 1
    if t:
        t.next = h
    return d.next, t
