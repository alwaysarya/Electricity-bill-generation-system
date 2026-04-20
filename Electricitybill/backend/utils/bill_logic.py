from datetime import date, timedelta

class BillLogic:

    @staticmethod
    def calculate_amount(units_consumed: int) -> float:
        units_consumed = int(units_consumed)

        if units_consumed <= 100:
            amount = units_consumed * 2
        elif units_consumed <= 300:
            amount = 100 * 2 + (units_consumed - 100) * 5
        else:
            amount = 100 * 2 + 200 * 5 + (units_consumed - 300) * 8

        return round(amount, 2)

    @staticmethod
    def next_due_date(generated_date: date) -> date:
        return generated_date + timedelta(days=15)

    @staticmethod
    def add_late_fee(amount: float, due_date: str) -> float:
        today = date.today()
        due = date.fromisoformat(due_date)

        if today > due:
            return amount + 50
        return amount

    @staticmethod
    def build_bill(customer_id: int, start_date: str, end_date: str, units_consumed: int):
        generated_date = date.today()
        due_date = BillLogic.next_due_date(generated_date)

        base_amount = BillLogic.calculate_amount(units_consumed)
        final_amount = BillLogic.add_late_fee(base_amount, due_date.isoformat())

        return {
            "customer_id": customer_id,
            "billing_period_start": start_date,
            "billing_period_end": end_date,
            "units_consumed": units_consumed,
            "amount_due": final_amount,
            "generated_date": generated_date.isoformat(),
            "due_date": due_date.isoformat(),
            "status": "unpaid"
        }