enum OrderActionResult { success, error }

class OrderActionMessage {
  final String text;
  final OrderActionResult result;
  const OrderActionMessage(this.text, this.result);
}
