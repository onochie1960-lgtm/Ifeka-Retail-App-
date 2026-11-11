-- 1. Create Schema
CREATE SCHEMA IF NOT EXISTS retail;

-- 2. Create Products Table & Policies
CREATE TABLE retail.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    selling_price NUMERIC(12,2) NOT NULL,
    quantity NUMERIC(12,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE retail.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all inserts" ON retail.products FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow all updates" ON retail.products FOR UPDATE USING (true);
CREATE POLICY "Allow all reads" ON retail.products FOR SELECT USING (true);

-- 3. Create Sales Table & Policies
CREATE TABLE retail.sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES retail.products(id),
    product_name VARCHAR(200),
    quantity_sold NUMERIC(12,2) NOT NULL,
    total_price NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE retail.sales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all sales access" ON retail.sales FOR ALL USING (true) WITH CHECK (true);

-- 4. Create Expenses Table & Policies
CREATE TABLE retail.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amount NUMERIC(12,2) NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE retail.expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all expenses access" ON retail.expenses FOR ALL USING (true) WITH CHECK (true);

-- 5. Create Dashboard View
CREATE OR REPLACE VIEW retail.daily_dashboard AS
SELECT 
    (SELECT COALESCE(SUM(total_price), 0) FROM retail.sales WHERE created_at::date = CURRENT_DATE) AS total_sales_today,
    (SELECT COALESCE(SUM(amount), 0) FROM retail.expenses WHERE created_at::date = CURRENT_DATE) AS total_expenses_today,
    (SELECT COUNT(*) FROM retail.products WHERE quantity <= 5) AS low_stock_items;
