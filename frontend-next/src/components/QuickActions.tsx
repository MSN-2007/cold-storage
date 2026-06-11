"use client";

import React from "react";
import { PlusCircle, Settings, Headset, ClipboardList, Activity } from "lucide-react";

interface QuickActionsProps {
  onAddGoodsClick: () => void;
  onRecommendedSettingsClick: () => void;
  onTechnicianSupportClick: () => void;
  onReportsClick: () => void;
  onDiagnosticsClick: () => void;
}

export default function QuickActions({
  onAddGoodsClick,
  onRecommendedSettingsClick,
  onTechnicianSupportClick,
  onReportsClick,
  onDiagnosticsClick,
}: QuickActionsProps) {
  const actions = [
    {
      icon: PlusCircle,
      title: "Add Goods",
      sub: "Add new inventory",
      color: "text-emerald-500",
      bg: "bg-emerald-50",
      border: "hover:border-emerald-200",
      id: "quick-action-add-goods",
      action: onAddGoodsClick,
    },
    {
      icon: Settings,
      title: "Recommended Settings",
      sub: "Apply best thresholds",
      color: "text-blue-500",
      bg: "bg-blue-50",
      border: "hover:border-blue-200",
      id: "quick-action-settings",
      action: onRecommendedSettingsClick,
    },
    {
      icon: Headset,
      title: "Technician Support",
      sub: "Request callout",
      color: "text-purple-500",
      bg: "bg-purple-50",
      border: "hover:border-purple-200",
      id: "quick-action-support",
      action: onTechnicianSupportClick,
    },
    {
      icon: ClipboardList,
      title: "Reports",
      sub: "View & export audits",
      color: "text-amber-500",
      bg: "bg-amber-50",
      border: "hover:border-amber-200",
      id: "quick-action-reports",
      action: onReportsClick,
    },
    {
      icon: Activity,
      title: "Diagnostics",
      sub: "Run telemetry check",
      color: "text-cyan-500",
      bg: "bg-cyan-50",
      border: "hover:border-cyan-200",
      id: "quick-action-diagnostics",
      action: onDiagnosticsClick,
    },
  ];

  return (
    <div id="quick-actions-bar" className="space-y-4">
      <h2 className="text-lg font-extrabold text-slate-900 tracking-tight">Quick Actions</h2>
      <div className="flex gap-4 overflow-x-auto pb-3 scrollbar-thin scrollbar-thumb-slate-200 scrollbar-track-transparent">
        {actions.map((a) => {
          const Icon = a.icon;
          return (
            <button
              id={a.id}
              key={a.title}
              onClick={a.action}
              className={`flex-1 min-w-[220px] bg-white border border-slate-200/80 p-4 rounded-2xl flex items-center gap-4 transition-all duration-200 text-left shadow-sm hover:shadow hover:bg-slate-50/20 ${a.border}`}
            >
              <div className={`p-3 rounded-xl ${a.bg} flex-shrink-0`}>
                <Icon className={`w-5 h-5 ${a.color}`} />
              </div>
              <div className="overflow-hidden">
                <h3 className="font-extrabold text-slate-900 text-sm tracking-tight truncate">
                  {a.title}
                </h3>
                <p className="text-[11px] text-slate-400 font-medium mt-0.5 leading-relaxed truncate">
                  {a.sub}
                </p>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}
