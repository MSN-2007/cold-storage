"use client";

import React from "react";
import { AlertTriangle, Droplet, Thermometer, FlaskConical, Wind } from "lucide-react";
import { ChamberAlert } from "@/types";

interface AlertsSectionProps {
  alerts: ChamberAlert[];
  onAlertDetailsClick: (alert: ChamberAlert) => void;
}

export default function AlertsSection({ alerts, onAlertDetailsClick }: AlertsSectionProps) {
  const getIcon = (type: string, severity: string) => {
    const iconColor = severity === "Critical" ? "text-red-500" : "text-amber-500";
    switch (type) {
      case "Droplet":
        return <Droplet className={`w-5 h-5 ${iconColor}`} />;
      case "Thermometer":
        return <Thermometer className={`w-5 h-5 ${iconColor}`} />;
      case "FlaskConical":
        return <FlaskConical className={`w-5 h-5 ${iconColor}`} />;
      case "Wind":
      default:
        return <Wind className={`w-5 h-5 ${iconColor}`} />;
    }
  };

  const getAlertColors = (severity: string) => {
    if (severity === "Critical") {
      return {
        bg: "bg-red-50/80",
        border: "border-red-200/80",
        accentText: "text-red-600",
        badgeBg: "bg-red-500/10 text-red-700",
      };
    } else {
      return {
        bg: "bg-amber-50/80",
        border: "border-amber-200/80",
        accentText: "text-amber-600",
        badgeBg: "bg-amber-500/10 text-amber-700",
      };
    }
  };

  return (
    <div id="alerts-section" className="space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className="bg-red-100 p-1.5 rounded-lg">
            <AlertTriangle className="w-5 h-5 text-red-600 animate-bounce" />
          </div>
          <h2 className="text-lg font-extrabold text-slate-900 tracking-tight">
            Immediate Action Required
          </h2>
        </div>
        <button
          onClick={() => alert("All Alert logs report")}
          className="text-sm font-bold text-accent hover:text-emerald-700 flex items-center gap-1 transition"
        >
          View All Alerts &rarr;
        </button>
      </div>

      <div
        id="alerts-scroll-deck"
        className="flex gap-4 overflow-x-auto pb-3 scrollbar-thin scrollbar-thumb-slate-200 scrollbar-track-transparent"
      >
        {alerts.map((a) => {
          const colors = getAlertColors(a.severity);
          return (
            <div
              id={`alert-card-${a.id}`}
              key={a.id}
              className={`min-w-[340px] max-w-[400px] flex-1 ${colors.bg} border ${colors.border} p-5 rounded-2xl flex flex-col justify-between shadow-sm hover:shadow transition-shadow duration-200`}
            >
              <div>
                <div className="flex justify-between items-center mb-4">
                  <span className="text-[10px] font-bold text-slate-700 bg-white/70 px-2.5 py-1 rounded-full border border-slate-200/40">
                    <span className="text-slate-900">{a.storageId}</span>
                    <span className="text-slate-400 mx-1.5">&rsaquo;</span>
                    <span className={colors.accentText}>{a.chamberName}</span>
                  </span>
                  <span className="text-[10px] text-slate-400 font-bold">{a.time}</span>
                </div>

                <div className="flex items-start gap-4">
                  <div className="p-2.5 bg-white rounded-xl shadow-sm border border-slate-100 flex-shrink-0">
                    {getIcon(a.iconType, a.severity)}
                  </div>
                  <div>
                    <h3 className="font-extrabold text-slate-900 text-base mb-1 tracking-tight">
                      {a.title}
                    </h3>
                    <p className="text-xs text-slate-500 mb-2 leading-relaxed">
                      Current:{" "}
                      <span className={`${colors.accentText} font-extrabold`}>
                        {a.currentValue}
                      </span>{" "}
                      <span className="mx-2 font-light text-slate-300">|</span> Required:{" "}
                      <span className="font-semibold text-slate-700">{a.requiredValue}</span>
                    </p>
                    <p className="text-sm font-bold text-slate-800 leading-tight">
                      {a.impactText}
                    </p>
                  </div>
                </div>
              </div>

              <button
                id={`btn-view-alert-${a.id}`}
                onClick={() => onAlertDetailsClick(a)}
                className={`mt-5 self-start px-4.5 py-2 rounded-xl border ${
                  a.severity === "Critical"
                    ? "border-red-200 hover:bg-red-500 hover:text-white"
                    : "border-amber-200 hover:bg-amber-500 hover:text-white"
                } ${colors.accentText} text-xs font-bold transition-all bg-white shadow-sm`}
              >
                Resolve Alert
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
}
