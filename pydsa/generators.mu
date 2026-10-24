# Generator helpers preloaded by sitecustomize.

from functools import wraps
from typing import Callable, Iterator, TypeVar

T = TypeVar("T")

def as_list(f: Callable[..., Iterator[T]]) -> Callable[..., [T]]
  """Run a generator function to exhaustion and return its yields as a list.

  A method that yields each answer as it finds it is returned whole, the way
  LeetCode expects it.
  """
  @wraps(f)
  def wrapper(*args, **kwargs) -> [T]: list(f(*args, **kwargs))
  wrapper
