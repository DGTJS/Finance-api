CREATE TYPE member_role AS ENUM ('ADMIN', 'MEMBER');

CREATE TYPE financial_account_type AS ENUM ('BANK', 'WALLET', 'CASH');

CREATE TYPE category_type AS ENUM ('INCOME', 'EXPENSE', 'BOTH');

CREATE TYPE transaction_type AS ENUM (
  'INCOME',
  'EXPENSE',
  'TRANSFER',
  'REFUND',
  'INVESTMENT'
);

CREATE TYPE transaction_purpose AS ENUM ('FAMILY', 'PERSONAL');

CREATE TYPE transaction_status AS ENUM (
  'PENDING',
  'CONFIRMED',
  'CANCELLED',
  'REVERSED'
);

CREATE TYPE credit_card_invoice_status AS ENUM (
  'OPEN',
  'CLOSED',
  'PAID',
  'OVERDUE',
  'CANCELLED'
);

CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  email_verified_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shared_accounts (
  id UUID PRIMARY KEY,
  owner_user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shared_account_members (
  id UUID PRIMARY KEY,
  shared_account_id UUID NOT NULL REFERENCES shared_accounts(id),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role member_role NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  left_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (user_id)
);

CREATE TABLE financial_accounts (
  id UUID PRIMARY KEY,
  shared_account_id UUID NOT NULL REFERENCES shared_accounts(id),
  owner_user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(100) NOT NULL,
  type financial_account_type NOT NULL,
  initial_balance_cents BIGINT NOT NULL DEFAULT 0,
  current_balance_cents BIGINT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
  id UUID PRIMARY KEY,
  shared_account_id UUID NOT NULL REFERENCES shared_accounts(id),
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(100),
  type category_type NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE credit_cards (
  id UUID PRIMARY KEY,
  shared_account_id UUID NOT NULL REFERENCES shared_accounts(id),
  owner_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  limit_cents BIGINT,
  closing_day INT NOT NULL,
  due_day INT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE credit_card_invoices (
  id UUID PRIMARY KEY,
  credit_card_id UUID NOT NULL REFERENCES credit_cards(id),
  reference_month INT NOT NULL,
  reference_year INT NOT NULL,
  due_date DATE NOT NULL,
  total_cents BIGINT NOT NULL DEFAULT 0,
  paid_cents BIGINT NOT NULL DEFAULT 0,
  status credit_card_invoice_status NOT NULL DEFAULT 'OPEN',
  paid_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (credit_card_id, reference_month, reference_year)
);

CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  shared_account_id UUID NOT NULL REFERENCES shared_accounts(id),
  responsible_user_id UUID NOT NULL REFERENCES users(id),

  financial_account_id UUID REFERENCES financial_accounts(id),
  category_id UUID REFERENCES categories(id),

  credit_card_id UUID REFERENCES credit_cards(id),
  invoice_id UUID REFERENCES credit_card_invoices(id),

  from_financial_account_id UUID REFERENCES financial_accounts(id),
  to_financial_account_id UUID REFERENCES financial_accounts(id),

  type transaction_type NOT NULL,
  purpose transaction_purpose NOT NULL,

  amount_cents BIGINT NOT NULL,
  description VARCHAR(255),
  transaction_date DATE NOT NULL,

  status transaction_status NOT NULL DEFAULT 'CONFIRMED',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY,
  shared_account_id UUID NOT NULL REFERENCES shared_accounts(id),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action VARCHAR(100) NOT NULL,
  entity_name VARCHAR(100) NOT NULL,
  entity_id UUID NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);