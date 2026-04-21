from django import forms

class CommaSeparatedIntegerWidget(forms.TextInput):
    def __init__(self, attrs=None, existing_bid=None):
        self.existing_bid = existing_bid
        super().__init__(attrs)

    def format_value(self, value):
        if value is None:
            return ''
        return "{:,}".format(value)

    def render(self, name, value, attrs=None, renderer=None):
        input_html = super().render(name, value, attrs, renderer)

        # No active bid — plain input, user types freely
        if not self.existing_bid:
            return input_html

        # Active bid exists — lock to increments only
        current_amount = "{:,}".format(self.existing_bid.amount)
        return f"""
        <div style="display:flex; gap:8px; align-items:center;">
            <button type="button" onclick="adjustBid('{name}', -1000)">-</button>
            {input_html}
            <button type="button" onclick="adjustBid('{name}', 1000)">+</button>
        </div>
        <p>Current bid: {current_amount}</p>
        <script>
        function adjustBid(name, delta) {{
            var input = document.querySelector('[name="' + name + '"]');
            var current = parseInt(input.value.replace(/,/g, '')) || 0;
            var next = Math.max(0, current + delta);
            input.value = next.toLocaleString();
        }}
        </script>
        """