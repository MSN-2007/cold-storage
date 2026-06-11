"use client";

import React from "react";
import { Database, CheckCircle2, AlertTriangle, AlertCircle, WifiOff } from "lucide-react";

interface MetricsRowProps {
  activeFilter: string;
  onFilterChange: (filter: "Total" | "Healthy" | "Warning" | "Critical" | "Offline") => void;
  counts: {
    total: number;
    healthy: number;
    warning: number;
    critical: number;
    offline: number;
  };
}

export default function MetricsRow({ activeFilter, onFilterChange, counts }: MetricsRowProps) {
  const metrics = [
    {
      label: "Total Storages",
      count: counts.total,
      sub: "All storage facilities",
      icon: Database,
      bg: "bg-blue-50/70",
      text: "text-blue-500",
      borderActive: "border-blue-500 ring-2 ring-blue-500/20",
      filter: "Total" as const,
    },
    {
      label: "Healthy",
      count: counts.healthy,
      sub: "Operating normally",
      icon: CheckCircle2,
      bg: "bg-emerald-50/70",
      text: "text-emerald-600",
      borderActive: "border-accent ring-2 ring-accent/20",
      filter: "Healthy" as const,
    },
    {
      label: "Warning",
      count: counts.warning,
      sub: "Attention required",
      icon: AlertTriangle,
      bg: "bg-amber-50/70",
      text: "text-amber-500",
      borderActive: "border-amber-500 ring-2 ring-amber-500/20",
      filter: "Warning" as const,
    },
    {
      label: "Critical",
      count: counts.critical,
      sub: "Immediate correction",
      icon: AlertCircle,
      bg: "bg-red-50/70",
      text: "text-red-500",
      borderActive: "border-red-500 ring-2 ring-red-500/20",
      filter: "Critical" as const,
    },
    {
      label: "Offline",
      count: counts.offline,
      sub: "No telemetry connection",
      icon: WifiOff,
      bg: "bg-slate-100/70",
      text: "text-slate-500",
      borderActive: "border-slate-500 ring-2 ring-slate-500/20",
      filter: "Offline" as const,
    },
  ];

  return (
    <div id="metrics-summary-row" className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
      {metrics.map((m) => {
        const isActive = activeFilter === m.filter;
        const Icon = m.icon;
        return (
          <button
            id={`metric-filter-card-${m.filter.toLowerCase()}`}
            key={m.label}
            onClick={() => onFilterChange(m.filter)}
            className={`bg-white p-5 rounded-2xl border text-left transition-all duration-200 shadow-sm ${
              isActive
                ? `${m.borderActive} scale-[1.01]`
                : "border-slate-200/80 hover:border-slate-300 hover:shadow"
            }`}
          >
            <div className="flex items-start gap-4">
              <div className={`p-3 rounded-xl ${m.bg} flex-shrink-0`}>
                <Icon className={`w-6 h-6 ${m.text}`} />
              </div>
              <div className="overflow-hidden">
                <p className="text-3xl font-extrabold text-slate-900 tracking-tight leading-none">
                  {m.count}
                </p>
                <p className="text-sm font-bold text-slate-800 mt-2 tracking-tight truncate">
                  {m.label}
                </p>
                <p className="text-xs text-slate-400 mt-0.5 font-medium leading-relaxed truncate">
                  {m.sub}
                </p>
              </div>
            </div>
          </button>
        );
      })}
    </div>
  );
}
