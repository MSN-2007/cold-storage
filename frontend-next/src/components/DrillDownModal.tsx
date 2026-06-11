"use client";

import React, { useState } from "react";
import {
  X,
  Droplet,
  Thermometer,
  FlaskConical,
  Wind,
  Database,
  Calendar,
  IndianRupee,
  Settings,
  TrendingUp,
  AlertTriangle,
  CheckCircle2,
} from "lucide-react";
import { StorageUnit, ChamberAlert } from "@/types";

interface DrillDownModalProps {
  isOpen: boolean;
  onClose: () => void;
  storageUnit: StorageUnit | null;
  alert: ChamberAlert | null;
  onResolveAlert?: (alertId: string) => void;
}

export default function DrillDownModal({
  isOpen,
  onClose,
  storageUnit,
  alert: currentAlert,
  onResolveAlert,
}: DrillDownModalProps) {
  const [activeTab, setActiveTab] = useState<"sensors" | "inventory" | "settings">("sensors");
  const [selectedMetric, setSelectedMetric] = useState<"temp" | "hum" | "co2" | "eth">("temp");

  if (!isOpen || !storageUnit) return null;

  // Mock historical data points for the SVG chart
  const historicalData: Record<"temp" | "hum" | "co2" | "eth", number[]> = {
    temp: [4.0, 4.2, 4.5, 4.1, 4.3, 4.8, 5.2, 4.7, 4.5, 4.2, 4.1, 4.3],
    hum: [88, 89, 91, 87, 85, 82, 80, 83, 86, 88, 90, 89],
    co2: [600, 610, 630, 620, 605, 595, 580, 615, 625, 640, 630, 620],
    eth: [0.5, 0.6, 0.7, 0.6, 0.5, 0.4, 0.6, 0.8, 0.9, 0.7, 0.6, 0.5],
  };

  // Adjust mock data slightly if this is an alert modal
  if (currentAlert) {
    if (currentAlert.iconType === "Droplet") {
      historicalData.hum = [88, 85, 80, 75, 70, 65, 60, 58, 56, 55, 54, 55];
    } else if (currentAlert.iconType === "Thermometer") {
      historicalData.temp = [5.0, 6.2, 8.5, 10.1, 11.3, 12.8, 14.2, 15.0, 15.2, 15.3, 15.2, 15.2];
    } else if (currentAlert.iconType === "FlaskConical") {
      historicalData.eth = [0.5, 0.7, 0.8, 1.0, 1.1, 1.2, 1.3, 1.25, 1.2, 1.21, 1.2, 1.2];
    }
  }

  const chartPoints = historicalData[selectedMetric];
  const minVal = Math.min(...chartPoints) * 0.9;
  const maxVal = Math.max(...chartPoints) * 1.1;
  const valRange = maxVal - minVal || 1;

  // Construct SVG points
  const width = 500;
  const height = 180;
  const padding = 25;
  const chartWidth = width - padding * 2;
  const chartHeight = height - padding * 2;

  const pointsString = chartPoints
    .map((val, idx) => {
      const x = padding + (idx / (chartPoints.length - 1)) * chartWidth;
      const y = padding + chartHeight - ((val - minVal) / valRange) * chartHeight;
      return `${x},${y}`;
    })
    .join(" ");

  const handleResolve = () => {
    if (currentAlert && onResolveAlert) {
      onResolveAlert(currentAlert.id);
      onClose();
    }
  };

  const getStatusBadgeClass = (status: string) => {
    switch (status) {
      case "Healthy":
        return "bg-emerald-50 text-emerald-700 border-emerald-200";
      case "Warning":
        return "bg-amber-50 text-amber-700 border-amber-200";
      case "Critical":
        return "bg-red-50 text-red-700 border-red-200";
      default:
        return "bg-slate-50 text-slate-700 border-slate-200";
    }
  };

  return (
    <div
      id="drilldown-modal-overlay"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-fade-in"
      onClick={onClose}
    >
      <div
        id="drilldown-modal-container"
        className="bg-white rounded-3xl w-full max-w-2xl shadow-2xl border border-slate-100 overflow-hidden transform transition-all duration-300 scale-100 flex flex-col h-[600px]"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-slate-950 text-white p-6 flex flex-col gap-2 flex-shrink-0">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="bg-accent/20 p-2.5 rounded-xl border border-accent/30 text-accent">
                <Database className="w-6 h-6 animate-pulse" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="font-extrabold text-xl tracking-tight">{storageUnit.name}</h3>
                  <span
                    className={`text-[10px] font-extrabold px-2 py-0.5 rounded-full border ${getStatusBadgeClass(
                      storageUnit.status
                    )} bg-white`}
                  >
                    {storageUnit.status}
                  </span>
                </div>
                <p className="text-slate-400 text-xs font-medium mt-0.5">
                  Chambers: {storageUnit.chambers} | Primary Crops: {storageUnit.crops}
                </p>
              </div>
            </div>
            <button
              id="close-drilldown-modal"
              onClick={onClose}
              className="text-slate-400 hover:text-white hover:bg-slate-800 p-2 rounded-xl transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Alert Banner if modal is triggered by Alert */}
          {currentAlert && (
            <div
              id="modal-alert-banner"
              className="mt-4 bg-red-500/15 border border-red-500/30 p-3 rounded-xl flex items-center justify-between text-xs animate-pulse"
            >
              <div className="flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 text-red-500" />
                <span className="font-bold text-red-300">
                  {currentAlert.title} in {currentAlert.chamberName}: {currentAlert.currentValue}
                </span>
              </div>
              <button
                id="btn-resolve-alert-modal"
                onClick={handleResolve}
                className="bg-red-600 hover:bg-red-700 text-white text-[10px] font-extrabold px-3 py-1.5 rounded-lg transition-colors shadow-lg shadow-red-700/20"
              >
                Dismiss & Resolve
              </button>
            </div>
          )}
        </div>

        {/* Tab Navigation */}
        <div className="flex border-b border-slate-200 flex-shrink-0 bg-slate-50/50">
          <button
            id="tab-sensors-analytics"
            onClick={() => setActiveTab("sensors")}
            className={`flex-1 py-3 text-xs font-extrabold tracking-wider uppercase border-b-2 transition ${
              activeTab === "sensors"
                ? "border-accent text-accent bg-white"
                : "border-transparent text-slate-500 hover:text-slate-900"
            }`}
          >
            Sensors & Analytics
          </button>
          <button
            id="tab-chamber-inventory"
            onClick={() => setActiveTab("inventory")}
            className={`flex-1 py-3 text-xs font-extrabold tracking-wider uppercase border-b-2 transition ${
              activeTab === "inventory"
                ? "border-accent text-accent bg-white"
                : "border-transparent text-slate-500 hover:text-slate-900"
            }`}
          >
            Inventory Batches ({storageUnit.batches.length})
          </button>
          <button
            id="tab-chamber-settings"
            onClick={() => setActiveTab("settings")}
            className={`flex-1 py-3 text-xs font-extrabold tracking-wider uppercase border-b-2 transition ${
              activeTab === "settings"
                ? "border-accent text-accent bg-white"
                : "border-transparent text-slate-500 hover:text-slate-900"
            }`}
          >
            Threshold Rules
          </button>
        </div>

        {/* Scrollable Tab Content */}
        <div className="flex-1 overflow-y-auto p-6 bg-slate-50/20">
          {/* Tab 1: Sensors */}
          {activeTab === "sensors" && (
            <div className="space-y-6 animate-fade-in">
              {/* Metric Selector Pills */}
              <div className="grid grid-cols-4 gap-2">
                {[
                  { key: "temp" as const, label: "Temp", val: `${storageUnit.metrics.temp}°C`, icon: Thermometer, color: "text-red-500" },
                  { key: "hum" as const, label: "Humidity", val: `${storageUnit.metrics.hum}%`, icon: Droplet, color: "text-blue-500" },
                  { key: "co2" as const, label: "CO₂", val: `${storageUnit.metrics.co2} ppm`, icon: Wind, color: "text-emerald-500" },
                  { key: "eth" as const, label: "Ethylene", val: `${storageUnit.metrics.eth} ppm`, icon: FlaskConical, color: "text-amber-500" },
                ].map((item) => (
                  <button
                    id={`btn-select-chart-${item.key}`}
                    key={item.key}
                    onClick={() => setSelectedMetric(item.key)}
                    className={`p-3 rounded-xl border text-center transition ${
                      selectedMetric === item.key
                        ? "bg-accent/5 border-accent shadow-sm"
                        : "bg-white border-slate-200/60 hover:border-slate-300"
                    }`}
                  >
                    <div className="flex justify-center mb-1">
                      <item.icon className={`w-4 h-4 ${item.color}`} />
                    </div>
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                      {item.label}
                    </p>
                    <p className="text-sm font-extrabold text-slate-900 mt-0.5">{item.val}</p>
                  </button>
                ))}
              </div>

              {/* Chart */}
              <div className="bg-white border border-slate-200/80 rounded-2xl p-5 shadow-sm space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <TrendingUp className="w-4 h-4 text-slate-400" />
                    <h4 className="text-xs font-extrabold text-slate-700 uppercase tracking-wider">
                      24h Historical Telemetry —{" "}
                      <span className="text-accent">{selectedMetric.toUpperCase()}</span>
                    </h4>
                  </div>
                  <span className="text-[10px] text-slate-400 font-bold">INTERVAL: 2 HOURS</span>
                </div>

                <div className="flex justify-center">
                  <svg width={width} height={height} className="overflow-visible">
                    {/* Background Grids */}
                    <line
                      x1={padding}
                      y1={padding}
                      x2={width - padding}
                      y2={padding}
                      stroke="#f1f5f9"
                      strokeWidth={1}
                    />
                    <line
                      x1={padding}
                      y1={padding + chartHeight / 2}
                      x2={width - padding}
                      y2={padding + chartHeight / 2}
                      stroke="#f1f5f9"
                      strokeWidth={1}
                    />
                    <line
                      x1={padding}
                      y1={padding + chartHeight}
                      x2={width - padding}
                      y2={padding + chartHeight}
                      stroke="#f1f5f9"
                      strokeWidth={1}
                    />

                    {/* Plot Line */}
                    <polyline
                      fill="none"
                      stroke="#00A878"
                      strokeWidth={3}
                      points={pointsString}
                      className="transition-all duration-300"
                    />

                    {/* Nodes */}
                    {chartPoints.map((val, idx) => {
                      const cx = padding + (idx / (chartPoints.length - 1)) * chartWidth;
                      const cy = padding + chartHeight - ((val - minVal) / valRange) * chartHeight;
                      return (
                        <circle
                          key={idx}
                          cx={cx}
                          cy={cy}
                          r={selectedMetric === "temp" && currentAlert?.iconType === "Thermometer" && idx === 8 ? 6 : 4}
                          fill={selectedMetric === "temp" && currentAlert?.iconType === "Thermometer" && idx === 8 ? "#ef4444" : "#ffffff"}
                          stroke={selectedMetric === "temp" && currentAlert?.iconType === "Thermometer" && idx === 8 ? "#ef4444" : "#00A878"}
                          strokeWidth={2}
                        />
                      );
                    })}
                  </svg>
                </div>
              </div>
            </div>
          )}

          {/* Tab 2: Inventory */}
          {activeTab === "inventory" && (
            <div className="space-y-4 animate-fade-in">
              <div className="flex items-center justify-between">
                <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider">
                  Chamber Goods Inventory Log
                </h4>
                <span className="text-[10px] text-accent font-extrabold bg-accent/10 px-2 py-0.5 rounded-full">
                  Total Batches: {storageUnit.batches.length}
                </span>
              </div>

              {storageUnit.batches.length === 0 ? (
                <div className="bg-white border border-dashed border-slate-200 rounded-2xl p-8 text-center space-y-2">
                  <div className="bg-slate-50 w-12 h-12 rounded-full flex items-center justify-center mx-auto text-slate-400">
                    <Database className="w-5 h-5" />
                  </div>
                  <p className="text-sm font-bold text-slate-600">No Inventory Deposited</p>
                  <p className="text-xs text-slate-400">
                    Submit via the sidebar "+ Add Goods" form to log crops in this chamber.
                  </p>
                </div>
              ) : (
                <div className="bg-white border border-slate-200/80 rounded-2xl overflow-hidden shadow-sm">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="bg-slate-50 border-b border-slate-200 text-[10px] font-extrabold text-slate-500 uppercase tracking-wider">
                        <th className="p-4">Batch ID</th>
                        <th className="p-4">Crop Type</th>
                        <th className="p-4">Quantity</th>
                        <th className="p-4">Entry Date</th>
                        <th className="p-4 text-right">Market Value</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100 text-xs font-bold text-slate-700">
                      {storageUnit.batches.map((batch) => (
                        <tr key={batch.id} className="hover:bg-slate-50/40">
                          <td className="p-4 text-slate-400 font-mono">{batch.id}</td>
                          <td className="p-4 text-slate-900">{batch.cropName}</td>
                          <td className="p-4">{batch.quantity}</td>
                          <td className="p-4 flex items-center gap-1 text-slate-500 font-semibold">
                            <Calendar className="w-3.5 h-3.5 text-slate-400" /> {batch.entryDate}
                          </td>
                          <td className="p-4 text-right text-emerald-600 font-extrabold">
                            {batch.value}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}

          {/* Tab 3: Settings */}
          {activeTab === "settings" && (
            <div className="space-y-6 animate-fade-in">
              <div className="flex items-center justify-between">
                <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider">
                  Chamber Alarm Threshold limits
                </h4>
                <button
                  onClick={() => alert("Custom Threshold rules saved successfully")}
                  className="bg-accent text-white text-[10px] font-bold px-3 py-1.5 rounded-lg hover:bg-emerald-600 transition shadow-sm"
                >
                  Save Rules
                </button>
              </div>

              <div className="space-y-5 bg-white border border-slate-200/80 rounded-2xl p-5 shadow-sm">
                {[
                  { label: "Temperature Range", min: storageUnit.settings.tempMin, max: storageUnit.settings.tempMax, unit: "°C", color: "accent" },
                  { label: "Humidity Limit (Min)", min: storageUnit.settings.humMin, max: storageUnit.settings.humMax, unit: "%", color: "blue-500" },
                  { label: "CO₂ Gas Cap", min: 0, max: storageUnit.settings.co2Max, unit: "ppm", color: "emerald-500" },
                  { label: "Ethylene Gas Cap", min: 0, max: storageUnit.settings.ethMax, unit: "ppm", color: "amber-500" },
                ].map((set, i) => (
                  <div key={i} className="space-y-2">
                    <div className="flex items-center justify-between text-xs font-extrabold text-slate-800">
                      <span>{set.label}</span>
                      <span className="text-slate-500">
                        {set.min} - {set.max} {set.unit}
                      </span>
                    </div>
                    <div className="h-2 bg-slate-100 rounded-full relative overflow-hidden">
                      <div className="absolute left-1/4 right-1/4 h-full bg-accent/20 border-l border-r border-accent/40" />
                      <div className="absolute left-[35%] w-[4px] h-full bg-accent" />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
