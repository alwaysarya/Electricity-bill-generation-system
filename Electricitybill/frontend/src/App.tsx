import { useEffect, useState } from "react";
import {
  Container,
  TextField,
  Button,
  Card,
  CardContent,
  Typography,
  Grid
} from "@mui/material";

import { Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  BarElement,
  CategoryScale,
  LinearScale
} from "chart.js";

ChartJS.register(BarElement, CategoryScale, LinearScale);

export default function App() {
  const [customers, setCustomers] = useState<any[]>([]);
  const [bills, setBills] = useState<any[]>([]);
  const [name, setName] = useState("");
  const [meter, setMeter] = useState("");
  const [phone, setPhone] = useState("");
  const [reading, setReading] = useState("");
  const [selectedCustomer, setSelectedCustomer] = useState<any>(null);

  // ---------------- LOAD ----------------
  const loadCustomers = () => {
    fetch("http://127.0.0.1:5050/customers")
      .then(res => res.json())
      .then(data => setCustomers(data));
  };

  const loadBills = () => {
    fetch("http://127.0.0.1:5050/bills")
      .then(res => res.json())
      .then(data => setBills(data));
  };

  useEffect(() => {
    loadCustomers();
    loadBills();
  }, []);

  // ---------------- ADD CUSTOMER ----------------
  const addCustomer = () => {
    fetch("http://127.0.0.1:5050/add_customer", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, meter, phone })
    }).then(() => {
      setName("");
      setMeter("");
      setPhone("");
      loadCustomers();
    });
  };

  // ---------------- GENERATE BILL ----------------
  const generateBill = () => {
    fetch("http://127.0.0.1:5050/generate_bill", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        customer_id: selectedCustomer.id,
        current_reading: Number(reading)
      })
    }).then(() => {
      setReading("");
      setSelectedCustomer(null);
      loadBills();
    });
  };

  // ---------------- PAY BILL ----------------
  const payBill = (id: number) => {
    fetch("http://127.0.0.1:5050/pay_bill", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ bill_id: id })
    }).then(() => loadBills());
  };

  // ---------------- CHART ----------------
  const data = {
    labels: bills.map(b => b.name),
    datasets: [
      {
        label: "Revenue",
        data: bills.map(b => b.total_amount),
        backgroundColor: "rgba(99,102,241,0.6)"
      }
    ]
  };

  return (
    <Container
      maxWidth="lg"
      sx={{
        background: "linear-gradient(135deg,#0f172a,#1e293b)",
        minHeight: "100vh",
        padding: 4,
        borderRadius: 3
      }}
    >
      {/* TITLE */}
      <Typography
        variant="h4"
        sx={{
          color: "white",
          textAlign: "center",
          mb: 4,
          fontWeight: "bold"
        }}
      >
        ⚡ Electricity Dashboard
      </Typography>

      {/* ADD CUSTOMER */}
      <Card
        sx={{
          mb: 4,
          borderRadius: 3,
          background: "#1e293b",
          color: "white"
        }}
      >
        <CardContent>
          <Typography variant="h6">Add Customer</Typography>

          <Grid container spacing={2}>
            <Grid item xs={4}>
              <TextField
                label="Name"
                fullWidth
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </Grid>
            <Grid item xs={4}>
              <TextField
                label="Meter"
                fullWidth
                value={meter}
                onChange={(e) => setMeter(e.target.value)}
              />
            </Grid>
            <Grid item xs={4}>
              <TextField
                label="Phone"
                fullWidth
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
              />
            </Grid>
          </Grid>

          <Button
            sx={{
              mt: 2,
              background: "linear-gradient(45deg,#6366f1,#06b6d4)"
            }}
            variant="contained"
            onClick={addCustomer}
          >
            Add Customer
          </Button>
        </CardContent>
      </Card>

      {/* CUSTOMERS */}
      <Typography sx={{ color: "white" }} variant="h6">
        Customers
      </Typography>

      <Grid container spacing={2}>
        {customers.map(c => (
          <Grid item xs={4} key={c.id}>
            <Card
              sx={{
                borderRadius: 3,
                background: "#1e293b",
                color: "white",
                transition: "0.3s",
                "&:hover": {
                  transform: "translateY(-5px)",
                  boxShadow: "0 15px 40px rgba(0,0,0,0.5)"
                }
              }}
            >
              <CardContent>
                <Typography>{c.name}</Typography>
                <Typography>Meter: {c.meter_number}</Typography>

                <Button
                  sx={{ mt: 1 }}
                  onClick={() => setSelectedCustomer(c)}
                >
                  Generate Bill
                </Button>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* GENERATE BILL */}
      {selectedCustomer && (
        <Card sx={{ mt: 4, background: "#1e293b", color: "white" }}>
          <CardContent>
            <Typography>
              Generate Bill for {selectedCustomer.name}
            </Typography>

            <TextField
              fullWidth
              label="Reading"
              value={reading}
              onChange={(e) => setReading(e.target.value)}
              sx={{ mt: 2 }}
            />

            <Button
              sx={{
                mt: 2,
                background: "linear-gradient(45deg,#6366f1,#06b6d4)"
              }}
              variant="contained"
              onClick={generateBill}
            >
              Generate
            </Button>
          </CardContent>
        </Card>
      )}

      {/* BILLS */}
      <Typography sx={{ mt: 4, color: "white" }} variant="h6">
        Bills
      </Typography>

      {bills.map(b => (
        <Card
          key={b.id}
          sx={{
            mb: 2,
            borderRadius: 3,
            background: "#1e293b",
            color: "white"
          }}
        >
          <CardContent>
            <Typography>{b.name}</Typography>
            <Typography>₹{b.total_amount}</Typography>

            <Typography color={b.status === "Paid" ? "lightgreen" : "red"}>
              Status: {b.status}
            </Typography>

            {b.status === "Unpaid" && (
              <Button onClick={() => payBill(b.id)}>Pay</Button>
            )}

            {/* PDF BUTTON */}
            <Button
              sx={{ ml: 2 }}
              variant="outlined"
              onClick={() =>
                window.open(`http://127.0.0.1:5050/download_bill/${b.id}`)
              }
            >
              📄 PDF
            </Button>
          </CardContent>
        </Card>
      ))}

      {/* CHART */}
      <Typography sx={{ mt: 4, color: "white" }} variant="h6">
        📊 Revenue Chart
      </Typography>

      <Card sx={{ p: 2, borderRadius: 3 }}>
        <Bar data={data} />
      </Card>
    </Container>
  );
}