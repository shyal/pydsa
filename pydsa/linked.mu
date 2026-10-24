from .nodes import ListNode

def build_linked_list(vals)
  dummy = it = ListNode()
  for v in vals
    it.next = ListNode(v)
    it = it.next
  dummy.next

def print_linked_list(head) -> none
  seen = set()
  while head and id(head) not in seen
    seen.add(id(head))
    print(head.val, end=head.next ? " -> " : "")
    head = head.next
  if head
    print(f" -> [{head.val}] (cycle)")
  print ""

def get_list_values(head)
  ret vals, seen = [], set()
  while head and id(head) not in seen
    seen.add(id(head))
    vals <- head.val
    head = head.next

def draw_linked_list(head) -> none
  if not head
    print "Empty linked list"
    return
  from PrettyPrint import PrettyPrintLinkedList
  pt = PrettyPrintLinkedList(x -> x.val, x -> x.next, x -> none,
    orientation=PrettyPrintLinkedList.Horizontal, color="\x1b[44m")
  pt(head)

def linked_list_reverse_k(h: ListNode?, k: float=inf) -> (ListNode?, ListNode?)
  """Reverse the first k nodes of the list at h, in place.

  Returns the new head and the new tail. The tail is the node that was h,
  and its next is the first node that was not reversed. With k left out,
  or a list shorter than k, the whole list is reversed and the tail's next
  is None.

  >>> head, tail = linked_list_reverse_k(build_linked_list([1, 2, 3, 4, 5]), 3)
  >>> get_list_values(head), tail.val
  ([3, 2, 1, 4, 5], 1)
  """
  d, t = ListNode(), h
  while h and k > 0
    d.next, h.next, h = h, d.next, h.next
    k -= 1
  if t
    t.next = h
  d.next, t
