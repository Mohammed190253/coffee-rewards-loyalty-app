import React from 'react';
import { Coffee, Calendar, Users, CheckCircle } from 'lucide-react';

const PREMIUM_GOLD_BORDER = '1px solid rgba(212, 175, 55, 0.2)';

const KPI_METRICS = [
  {
    key: 'totalMenuItems',
    label: 'Total Menu Items',
    Icon: Coffee,
  },
  {
    key: 'totalEvents',
    label: 'Active Circles',
    Icon: Calendar,
  },
  {
    key: 'totalBookings',
    label: 'Total Booked Seats',
    Icon: Users,
  },
  {
    key: 'totalCheckins',
    label: 'Attendee Check-ins',
    Icon: CheckCircle,
  },
];

function KPICard({ label, value, Icon }) {
  return (
    <div
      className="bg-astrolabe-teal p-6 rounded-2xl shadow-sm flex items-center justify-between"
      style={{ border: PREMIUM_GOLD_BORDER }}
    >
      <div>
        <p className="text-xs text-astrolabe-goldLight font-semibold uppercase tracking-wider">
          {label}
        </p>
        <h3 className="text-3xl font-extrabold text-astrolabe-cream mt-1.5">{value}</h3>
      </div>
      <div
        className="w-12 h-12 bg-astrolabe-tealLight text-astrolabe-gold rounded-xl flex items-center justify-center"
        style={{ border: PREMIUM_GOLD_BORDER }}
      >
        <Icon className="w-5 h-5" />
      </div>
    </div>
  );
}

export default function KPIGrid({ metrics }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      {KPI_METRICS.map(({ key, label, Icon }) => (
        <KPICard
          key={key}
          label={label}
          value={metrics?.[key] ?? 0}
          Icon={Icon}
        />
      ))}
    </div>
  );
}
