-- SCRIPT TO CREATE NEW INVOICE TABLES WITH PROPER RLS
-- Run this in your Supabase SQL Editor

-- First, drop any existing tables to avoid conflicts
DROP TABLE IF EXISTS invoice_payments CASCADE;
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;

-- Table for storing invoice records
CREATE TABLE public.invoices (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  guest_id TEXT,  -- Changed to TEXT to be more flexible with IDs
  guest_name TEXT NOT NULL,
  room_number TEXT NOT NULL,
  room_type TEXT NOT NULL DEFAULT 'Standard',
  check_in_date TEXT NOT NULL,  -- Storing as TEXT to avoid Date conversion issues
  check_out_date TEXT NOT NULL,
  nights INTEGER NOT NULL DEFAULT 1,
  room_rate DECIMAL(10, 2) NOT NULL DEFAULT 0,
  room_total DECIMAL(10, 2) NOT NULL DEFAULT 0,
  service_total DECIMAL(10, 2) NOT NULL DEFAULT 0,
  amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'Pending',
  has_service_items BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID -- Made optional (no REFERENCES to avoid auth.users issues)
);

-- Table for storing invoice line items (services, etc.)
CREATE TABLE public.invoice_items (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  invoice_id BIGINT NOT NULL REFERENCES public.invoices(id) ON DELETE CASCADE,
  service_id TEXT,  -- Optional reference to a service
  item_name TEXT NOT NULL,
  item_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
  item_date TEXT,  -- Storing as TEXT to avoid Date conversion issues
  item_type TEXT DEFAULT 'service',
  status TEXT DEFAULT 'Pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ENABLE ROW LEVEL SECURITY
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;

-- DROP EXISTING POLICIES IF ANY
DROP POLICY IF EXISTS "Invoices are viewable by authenticated users" ON public.invoices;
DROP POLICY IF EXISTS "Invoices are insertable by authenticated users" ON public.invoices;
DROP POLICY IF EXISTS "Invoices are updatable by authenticated users" ON public.invoices;
DROP POLICY IF EXISTS "Invoices are deletable by authenticated users" ON public.invoices;

DROP POLICY IF EXISTS "Invoice items are viewable by authenticated users" ON public.invoice_items;
DROP POLICY IF EXISTS "Invoice items are insertable by authenticated users" ON public.invoice_items;
DROP POLICY IF EXISTS "Invoice items are updatable by authenticated users" ON public.invoice_items;
DROP POLICY IF EXISTS "Invoice items are deletable by authenticated users" ON public.invoice_items;

-- CREATE NEW RLS POLICIES FOR INVOICES
-- View policy - Any authenticated user can view all invoices
CREATE POLICY "Invoices viewable by authenticated users" 
ON public.invoices 
FOR SELECT 
USING (auth.role() = 'authenticated');

-- Insert policy - Authenticated users can insert invoices and record who created them
CREATE POLICY "Invoices insertable by authenticated users" 
ON public.invoices 
FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Update policy - Authenticated users can update any invoice
CREATE POLICY "Invoices updatable by authenticated users" 
ON public.invoices 
FOR UPDATE 
USING (auth.role() = 'authenticated');

-- Delete policy - Authenticated users can delete any invoice
CREATE POLICY "Invoices deletable by authenticated users" 
ON public.invoices 
FOR DELETE 
USING (auth.role() = 'authenticated');

-- CREATE NEW RLS POLICIES FOR INVOICE ITEMS
-- View policy - Any authenticated user can view all invoice items
CREATE POLICY "Invoice items viewable by authenticated users" 
ON public.invoice_items 
FOR SELECT 
USING (auth.role() = 'authenticated');

-- Insert policy - Authenticated users can insert invoice items
CREATE POLICY "Invoice items insertable by authenticated users" 
ON public.invoice_items 
FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Update policy - Authenticated users can update any invoice item
CREATE POLICY "Invoice items updatable by authenticated users" 
ON public.invoice_items 
FOR UPDATE 
USING (auth.role() = 'authenticated');

-- Delete policy - Authenticated users can delete any invoice item
CREATE POLICY "Invoice items deletable by authenticated users" 
ON public.invoice_items 
FOR DELETE 
USING (auth.role() = 'authenticated');

-- CREATE FUNCTION FOR UPDATING TIMESTAMPS
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREATE TRIGGER TO UPDATE TIMESTAMPS
DROP TRIGGER IF EXISTS update_invoices_timestamp ON public.invoices;
CREATE TRIGGER update_invoices_timestamp
BEFORE UPDATE ON public.invoices
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- CREATE THE REALTIME PUBLICATION IF IT DOESN'T EXIST
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime'
  ) THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
END
$$;

-- ENABLE REALTIME SUBSCRIPTIONS
ALTER PUBLICATION supabase_realtime ADD TABLE public.invoices;
ALTER PUBLICATION supabase_realtime ADD TABLE public.invoice_items;

-- GRANT PERMISSIONS FOR RLS TO WORK PROPERLY
GRANT ALL ON public.invoices TO authenticated;
GRANT ALL ON public.invoice_items TO authenticated;
GRANT USAGE ON SEQUENCE public.invoices_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE public.invoice_items_id_seq TO authenticated; 