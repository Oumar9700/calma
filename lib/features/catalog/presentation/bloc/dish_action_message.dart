enum DishActionResult { success, error }

class DishActionMessage {
  final String text;
  final DishActionResult result;
  const DishActionMessage(this.text, this.result);
}
