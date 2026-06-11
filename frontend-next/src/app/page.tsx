"use client";

import React, { useState, useEffect } from "react";
import Sidebar from "@/components/Sidebar";
import Header from "@/components/Header";
import MetricsRow from "@/components/MetricsRow";
import AlertsSection from "@/components/AlertsSection";
import StorageGrid from "@/components/StorageGrid";
import QuickActions from "@/components/QuickActions";
import AddGoodsModal from "@/components/AddGoodsModal";
import DrillDownModal from "@/components/DrillDownModal";
import { StorageUnit, ChamberAlert, CropBatch } from "@/types";
import {
  Database,
  Box,
  AlertTriangle,
  BarChart2,
  Wrench,
  Settings,
  HelpCircle,
  TrendingUp,
  Activity,
  PlusCircle,
  FileSpreadsheet,
  Calendar,
  IndianRupee,
  Cpu,
  CheckCircle2,
} from "lucide-react";

export default function Home() {
  // Navigation tabs state
  const [activeTab, setActiveTab] = useState<string>("Dashboard");
  const [collapsed, setCollapsed] = useState<boolean>(false);
  const [appMode, setAppMode] = useState<"Simple" | "Advanced">("Advanced");

  // Core Data States
  const [storageUnits, setStorageUnits] = useState<StorageUnit[]>([
    {
      id: "Storage A",
      name: "Storage A",
      status: "Healthy",
      chambers: 2,
      crops: "Tomato, Potato",
      health: 95,
      metrics: { temp: 4.2, hum: 88, co2: 620, eth: 0.7 },
      settings: { tempMin: 2, tempMax: 6, humMin: 85, humMax: 95, co2Max: 800, ethMax: 1.0 },
      batches: [
        { id: "B-001", cropName: "Tomato", quantity: "12,000 kg", entryDate: "2026-06-01", value: "₹3,50,000" },
        { id: "B-002", cropName: "Potato", quantity: "25,000 kg", entryDate: "2026-05-20", value: "₹5,00,000" },
      ],
    },
    {
      id: "Storage B",
      name: "Storage B",
      status: "Warning",
      chambers: 3,
      crops: "Leafy Veg, Carrot",
      health: 72,
      metrics: { temp: 3.8, hum: 55, co2: 680, eth: 1.2 },
      settings: { tempMin: 1, tempMax: 4, humMin: 90, humMax: 98, co2Max: 1000, ethMax: 1.5 },
      batches: [
        { id: "B-003", cropName: "Leafy Veg", quantity: "4,000 kg", entryDate: "2026-06-08", value: "₹1,20,000" },
        { id: "B-004", cropName: "Carrot", quantity: "8,000 kg", entryDate: "2026-06-03", value: "₹2,40,000" },
      ],
    },
    {
      id: "Storage C",
      name: "Storage C",
      status: "Critical",
      chambers: 2,
      crops: "Banana",
      health: 45,
      metrics: { temp: 15.2, hum: 90, co2: 550, eth: 0.9 },
      settings: { tempMin: 13, tempMax: 16, humMin: 85, humMax: 95, co2Max: 1200, ethMax: 2.0 },
      batches: [
        { id: "B-005", cropName: "Banana", quantity: "15,000 kg", entryDate: "2026-06-09", value: "₹4,50,000" },
      ],
    },
    {
      id: "Storage D",
      name: "Storage D",
      status: "Healthy",
      chambers: 1,
      crops: "Onion",
      health: 89,
      metrics: { temp: 4.1, hum: 85, co2: 600, eth: 0.5 },
      settings: { tempMin: 0, tempMax: 2, humMin: 65, humMax: 70, co2Max: 800, ethMax: 0.5 },
      batches: [
        { id: "B-006", cropName: "Onion", quantity: "30,000 kg", entryDate: "2026-05-15", value: "₹6,00,000" },
      ],
    },
  ]);

  const [alerts, setAlerts] = useState<ChamberAlert[]>([
    {
      id: "A1",
      title: "Humidity Low",
      storageId: "Storage B",
      chamberName: "Chamber 2",
      time: "5 min ago",
      currentValue: "55%",
      requiredValue: "85-95%",
      impactText: "Estimated shelf life loss: 2 days",
      iconType: "Droplet",
      severity: "Critical",
    },
    {
      id: "A2",
      title: "Temperature High",
      storageId: "Storage C",
      chamberName: "Chamber 1",
      time: "10 min ago",
      currentValue: "15.2°C",
      requiredValue: "2-6°C",
      impactText: "Estimated inventory at risk: ₹50,000",
      iconType: "Thermometer",
      severity: "Critical",
    },
    {
      id: "A3",
      title: "Ethylene High",
      storageId: "Storage B",
      chamberName: "Chamber 3",
      time: "25 min ago",
      currentValue: "1.2 ppm",
      requiredValue: "< 1 ppm",
      impactText: "May cause faster ripening",
      iconType: "FlaskConical",
      severity: "Warning",
    },
  ]);

  // Filtering Metrics state
  const [activeFilter, setActiveFilter] = useState<
    "Total" | "Healthy" | "Warning" | "Critical" | "Offline"
  >("Total");

  // Time stamp & refresh loading states
  const [lastUpdated, setLastUpdated] = useState<string>("");
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);

  // Modals overlays state
  const [isAddGoodsOpen, setIsAddGoodsOpen] = useState<boolean>(false);
  const [isDrillDownOpen, setIsDrillDownOpen] = useState<boolean>(false);
  const [selectedStorageUnit, setSelectedStorageUnit] = useState<StorageUnit | null>(null);
  const [selectedAlert, setSelectedAlert] = useState<ChamberAlert | null>(null);

  // Set initial update timestamp
  useEffect(() => {
    const formatTime = () =>
      new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
    setLastUpdated(formatTime());
  }, []);

  // 1. LIVE IoT TELEMETRY FLUCTUATIONS
  // Runs every 4 seconds, fluctuating metrics by exactly +/- 0.1 units subtly
  useEffect(() => {
    const interval = setInterval(() => {
      setStorageUnits((prevUnits) =>
        prevUnits.map((su) => {
          const deltaTemp = (Math.random() * 0.2 - 0.1);
          const deltaHum = Math.round(Math.random() * 2 - 1);
          const deltaCo2 = Math.round(Math.random() * 8 - 4);
          const deltaEth = (Math.random() * 0.2 - 0.1);

          return {
            ...su,
            metrics: {
              temp: parseFloat((su.metrics.temp + deltaTemp).toFixed(1)),
              hum: Math.min(100, Math.max(0, su.metrics.hum + deltaHum)),
              co2: Math.max(0, su.metrics.co2 + deltaCo2),
              eth: parseFloat(Math.max(0, su.metrics.eth + deltaEth).toFixed(2)),
            },
          };
        })
      );
    }, 4000);

    return () => clearInterval(interval);
  }, []);

  // Manual trigger reload state simulating sensor refresh
  const handleManualRefresh = () => {
    setIsRefreshing(true);
    setTimeout(() => {
      const formatTime = () =>
        new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
      setLastUpdated(formatTime());
      setIsRefreshing(false);
    }, 800);
  };

  // Add Inventory goods batch state manipulator
  const handleAddGoods = (
    storageId: string,
    batchData: { cropName: string; quantity: string; entryDate: string; value: string }
  ) => {
    setStorageUnits((prevUnits) =>
      prevUnits.map((su) => {
        if (su.id === storageId) {
          const newId = `B-${Math.floor(100 + Math.random() * 900)}`;
          const newBatch: CropBatch = {
            id: newId,
            cropName: batchData.cropName,
            quantity: batchData.quantity,
            entryDate: batchData.entryDate,
            value: batchData.value,
          };

          // Append to crops string list if not already present
          let updatedCrops = su.crops;
          if (!su.crops.toLowerCase().includes(batchData.cropName.toLowerCase())) {
            updatedCrops = `${su.crops}, ${batchData.cropName}`;
          }

          return {
            ...su,
            crops: updatedCrops,
            batches: [...su.batches, newBatch],
            // Slightly improve health index due to fresh batch deposit audit
            health: Math.min(100, su.health + 2),
          };
        }
        return su;
      })
    );
  };

  // Resolve Alert action
  const handleResolveAlert = (alertId: string) => {
    setAlerts((prev) => prev.filter((a) => a.id !== alertId));
    // Improve corresponding storage health state
    const resolvedAlert = alerts.find((a) => a.id === alertId);
    if (resolvedAlert) {
      setStorageUnits((prev) =>
        prev.map((su) => {
          if (su.name === resolvedAlert.storageId) {
            return {
              ...su,
              status: "Healthy",
              health: Math.min(100, su.health + 15),
            };
          }
          return su;
        })
      );
    }
  };

  // Drilldown card handler
  const handleOpenStorageDetails = (su: StorageUnit) => {
    setSelectedStorageUnit(su);
    setSelectedAlert(null);
    setIsDrillDownOpen(true);
  };

  // Drilldown alert handler
  const handleOpenAlertDetails = (alert: ChamberAlert) => {
    const matchedStorage = storageUnits.find((su) => su.name === alert.storageId) || null;
    setSelectedStorageUnit(matchedStorage);
    setSelectedAlert(alert);
    setIsDrillDownOpen(true);
  };

  // Calculate status counts dynamically
  const counts = {
    total: storageUnits.length,
    healthy: storageUnits.filter((su) => su.status === "Healthy").length,
    warning: storageUnits.filter((su) => su.status === "Warning").length,
    critical: storageUnits.filter((su) => su.status === "Critical").length,
    offline: storageUnits.filter((su) => su.status === "Offline").length,
  };

  return (
    <div className="flex h-screen overflow-hidden bg-background text-slate-800 font-sans">
      {/* 1. SIDEBAR */}
      <Sidebar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        collapsed={collapsed}
        setCollapsed={setCollapsed}
        onAddGoodsClick={() => setIsAddGoodsOpen(true)}
        appMode={appMode}
        setAppMode={setAppMode}
      />

      {/* 2. BODY CONTENT */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <Header
          lastUpdated={lastUpdated}
          onRefresh={handleManualRefresh}
          isRefreshing={isRefreshing}
        />

        {/* View Switcher Panels (Routing matrix) */}
        <main className="flex-1 overflow-y-auto p-8 max-w-7xl mx-auto w-full space-y-8">
          {activeTab === "Dashboard" && (
            <div className="space-y-8 animate-fade-in">
              {/* Summary Cards */}
              <MetricsRow
                activeFilter={activeFilter}
                onFilterChange={setActiveFilter}
                counts={counts}
              />

              {/* Alert Deck */}
              {alerts.length > 0 && (
                <AlertsSection alerts={alerts} onAlertDetailsClick={handleOpenAlertDetails} />
              )}

              {/* Device grid */}
              <StorageGrid
                storageUnits={storageUnits}
                onViewDetails={handleOpenStorageDetails}
                activeFilter={activeFilter}
              />

              {/* Action Buttons */}
              <QuickActions
                onAddGoodsClick={() => setIsAddGoodsOpen(true)}
                onRecommendedSettingsClick={() => alert("Applying default settings recommendations...")}
                onTechnicianSupportClick={() => alert("Opening live technician service request form...")}
                onReportsClick={() => setActiveTab("Reports")}
                onDiagnosticsClick={() => alert("Diagnostics analysis: All gateway systems normal")}
              />
            </div>
          )}

          {activeTab === "My Storages" && (
            <div className="space-y-6 animate-fade-in">
              <div className="border-b border-slate-200 pb-4">
                <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">Storage Facilities View</h2>
                <p className="text-sm text-slate-500 mt-1">Manage chambers, telemetry limits, and health factors.</p>
              </div>
              <MetricsRow
                activeFilter={activeFilter}
                onFilterChange={setActiveFilter}
                counts={counts}
              />
              <StorageGrid
                storageUnits={storageUnits}
                onViewDetails={handleOpenStorageDetails}
                activeFilter={activeFilter}
              />
            </div>
          )}

          {activeTab === "Inventory" && (
            <div className="space-y-6 animate-fade-in">
              <div className="flex justify-between items-center border-b border-slate-200 pb-4">
                <div>
                  <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">Active Batch Logs</h2>
                  <p className="text-sm text-slate-500 mt-1">Unified view of all crop deposits inside your chambers.</p>
                </div>
                <button
                  id="btn-inventory-add-goods"
                  onClick={() => setIsAddGoodsOpen(true)}
                  className="bg-accent hover:bg-emerald-600 text-white font-bold text-xs py-2.5 px-4 rounded-xl flex items-center gap-1.5 transition-all shadow-sm"
                >
                  <PlusCircle className="w-4 h-4" /> Deposit Batch
                </button>
              </div>

              {/* Cumulative inventory table */}
              <div className="bg-white border border-slate-200/80 rounded-2xl overflow-hidden shadow-sm">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-slate-50 border-b border-slate-200 text-[10px] font-extrabold text-slate-500 uppercase tracking-wider">
                      <th className="p-4">Facility</th>
                      <th className="p-4">Batch ID</th>
                      <th className="p-4">Crop</th>
                      <th className="p-4">Quantity</th>
                      <th className="p-4">Deposit Date</th>
                      <th className="p-4 text-right">Value (INR)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 text-xs font-bold text-slate-700">
                    {storageUnits.flatMap((su) =>
                      su.batches.map((batch) => (
                        <tr key={batch.id} className="hover:bg-slate-50/40">
                          <td className="p-4 text-slate-900 font-extrabold">{su.name}</td>
                          <td className="p-4 text-slate-400 font-mono">{batch.id}</td>
                          <td className="p-4">{batch.cropName}</td>
                          <td className="p-4">{batch.quantity}</td>
                          <td className="p-4 text-slate-500 font-semibold">{batch.entryDate}</td>
                          <td className="p-4 text-right text-emerald-600 font-extrabold">{batch.value}</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === "Alerts" && (
            <div className="space-y-6 animate-fade-in">
              <div className="border-b border-slate-200 pb-4">
                <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">Emergency Alerts Log</h2>
                <p className="text-sm text-slate-500 mt-1">Real-time issues requiring technician review.</p>
              </div>

              {alerts.length === 0 ? (
                <div className="bg-white border border-slate-200 rounded-3xl p-12 text-center max-w-xl mx-auto space-y-3">
                  <div className="bg-emerald-50 text-emerald-600 w-14 h-14 rounded-full flex items-center justify-center mx-auto border border-emerald-100 shadow-sm shadow-emerald-100/30">
                    <CheckCircle2 className="w-6 h-6" />
                  </div>
                  <p className="text-base font-extrabold text-slate-800">All Systems Operational</p>
                  <p className="text-xs text-slate-400 leading-relaxed">
                    No active sensor warnings or alerts. If values exceed threshold bounds, alarm alerts will trigger here.
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  {alerts.map((alert) => (
                    <div
                      key={alert.id}
                      className="bg-white border border-slate-200 p-5 rounded-2xl flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm"
                    >
                      <div className="flex items-start gap-4">
                        <div
                          className={`p-3 rounded-xl flex-shrink-0 ${
                            alert.severity === "Critical" ? "bg-red-50 text-red-500" : "bg-amber-50 text-amber-500"
                          }`}
                        >
                          <AlertTriangle className="w-5 h-5" />
                        </div>
                        <div>
                          <h4 className="font-extrabold text-slate-900 text-sm tracking-tight flex items-center gap-2">
                            {alert.title} in {alert.storageId} ({alert.chamberName})
                            <span
                              className={`text-[9px] font-extrabold px-2 py-0.5 rounded-full border uppercase tracking-wider ${
                                alert.severity === "Critical"
                                  ? "bg-red-50 border-red-200 text-red-700"
                                  : "bg-amber-50 border-amber-200 text-amber-700"
                              }`}
                            >
                              {alert.severity}
                            </span>
                          </h4>
                          <p className="text-xs text-slate-500 mt-1 leading-relaxed">
                            Current Value: <span className="font-bold text-slate-800">{alert.currentValue}</span> | Required: {alert.requiredValue}
                          </p>
                          <p className="text-xs text-red-600 font-bold mt-0.5">{alert.impactText}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <span className="text-[10px] text-slate-400 font-semibold">{alert.time}</span>
                        <button
                          onClick={() => handleResolveAlert(alert.id)}
                          className="bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold px-4 py-2 rounded-xl transition"
                        >
                          Dismiss Alert
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {activeTab === "Reports" && (
            <div className="space-y-6 animate-fade-in">
              <div className="border-b border-slate-200 pb-4">
                <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">System Performance Audits</h2>
                <p className="text-sm text-slate-500 mt-1">Export sensor audits and chamber performance logs.</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {[
                  { title: "Gateway Status Log", desc: "Audit connection logs of BLE/MQTT IoT hubs.", type: "system" },
                  { title: "Chamber Thermal Report", desc: "Thermal fluctuation reports for Storage B & C.", type: "sensor" },
                  { title: "Gas Levels Audit", desc: "Daily ethylene levels and CO₂ emission audits.", type: "gas" },
                ].map((rep, idx) => (
                  <div key={idx} className="bg-white border border-slate-200/80 p-5 rounded-2xl shadow-sm space-y-4">
                    <div className="bg-slate-50 p-3 rounded-xl w-11 h-11 flex items-center justify-center border border-slate-100 text-slate-400">
                      <FileSpreadsheet className="w-5 h-5" />
                    </div>
                    <div>
                      <h4 className="font-extrabold text-slate-900 text-sm tracking-tight">{rep.title}</h4>
                      <p className="text-xs text-slate-400 mt-1 leading-relaxed">{rep.desc}</p>
                    </div>
                    <button
                      onClick={() => alert(`Exporting ${rep.title} CSV file...`)}
                      className="w-full bg-slate-50 hover:bg-slate-100 text-slate-700 text-xs font-bold py-2 rounded-lg border border-slate-200/60 transition"
                    >
                      Export CSV Report
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === "Technician" && (
            <div className="space-y-6 animate-fade-in">
              <div className="border-b border-slate-200 pb-4">
                <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">Duty Technical Callouts</h2>
                <p className="text-sm text-slate-500 mt-1">Book maintenance audits for anomalous gas sensors.</p>
              </div>

              <div className="bg-white border border-slate-200 p-6 rounded-2xl max-w-lg space-y-5">
                <div className="flex items-center gap-3">
                  <div className="bg-accent/10 p-2.5 rounded-xl border border-accent/20 text-accent">
                    <Wrench className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-extrabold text-slate-900 text-sm">Schedule Maintenance Callout</h3>
                    <p className="text-xs text-slate-400 mt-0.5">Automated technician booking via API</p>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="space-y-1">
                    <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Select Storage chamber</label>
                    <select className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-xs font-bold text-slate-800 focus:outline-none">
                      {storageUnits.map((su) => (
                        <option key={su.id} value={su.id}>{su.name}</option>
                      ))}
                    </select>
                  </div>
                  <div className="space-y-1">
                    <label className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Service Description</label>
                    <textarea
                      placeholder="Explain anomalies (e.g. ethylene sensor calibration issues)"
                      className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-xs font-medium text-slate-800 focus:outline-none h-24"
                    />
                  </div>
                </div>

                <button
                  onClick={() => alert("Duty service callout booked! Dispatch code: CS-9321")}
                  className="w-full bg-accent hover:bg-emerald-600 text-white font-bold text-xs py-3 rounded-xl transition"
                >
                  Book Service Callout
                </button>
              </div>
            </div>
          )}

          {activeTab === "Settings" && (
            <div className="space-y-6 animate-fade-in">
              <div className="border-b border-slate-200 pb-4">
                <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">Operating System Settings</h2>
                <p className="text-sm text-slate-500 mt-1">Configure telemetry rules, notifications, and app preferences.</p>
              </div>

              <div className="bg-white border border-slate-200 p-6 rounded-2xl max-w-xl space-y-6">
                <div>
                  <h3 className="font-extrabold text-slate-900 text-base mb-1 tracking-tight">Notification Channels</h3>
                  <p className="text-xs text-slate-400">Trigger warnings when thresholds are violated.</p>
                </div>

                <div className="space-y-4">
                  {[
                    { title: "SMS Alarms Alerting", desc: "Dispatch urgent text alerts to on-duty technician.", checked: true },
                    { title: "Email Batch Audits", desc: "Receive automated daily email reports on inventory health.", checked: false },
                    { title: "Sound Siren Warnings", desc: "Trigger local hardware sirens inside warehouse.", checked: true },
                  ].map((notif, idx) => (
                    <div key={idx} className="flex items-center justify-between border-b border-slate-100 pb-3 last:border-b-0">
                      <div>
                        <h4 className="font-bold text-slate-800 text-sm">{notif.title}</h4>
                        <p className="text-xs text-slate-400 leading-relaxed mt-0.5">{notif.desc}</p>
                      </div>
                      <div className="relative inline-flex items-center cursor-pointer">
                        <input type="checkbox" defaultChecked={notif.checked} className="sr-only peer" />
                        <div className="w-9 h-5 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-accent" />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {activeTab === "FAQ" && (
            <div className="space-y-6 animate-fade-in">
              <div className="border-b border-slate-200 pb-4">
                <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight">Frequently Asked Questions</h2>
                <p className="text-sm text-slate-500 mt-1">Get quick help about your ColdSmart operating system.</p>
              </div>

              <div className="max-w-2xl space-y-4">
                {[
                  {
                    q: "How does the live simulated sensor fluctuation work?",
                    a: "Each chamber features built-in IoT gateways broadcasting telemetry data. Sensor values subtly fluctuate by +/- 0.1 every 4 seconds to reflect actual gas expansion and thermal drafts.",
                  },
                  {
                    q: "What causes an 'Ethylene High' alert warning?",
                    a: "Ethylene gas (C₂H₄) is a natural plant hormone that triggers ripening. Exceeding threshold limits (1.0 ppm) speeds up decay. Immediate ventilation is recommended.",
                  },
                  {
                    q: "How can I update storage threshold parameters?",
                    a: "Navigate to the chamber's 'Threshold Rules' tab via the 'View Details' modal to configure custom limits, and click 'Save Rules'.",
                  },
                ].map((faq, idx) => (
                  <details key={idx} className="group bg-white border border-slate-200 rounded-2xl p-5 shadow-sm [&_summary::-webkit-details-marker]:hidden">
                    <summary className="flex items-center justify-between cursor-pointer focus:outline-none">
                      <h4 className="font-extrabold text-slate-900 text-sm tracking-tight">{faq.q}</h4>
                      <span className="text-slate-400 group-open:rotate-180 transition-transform">&darr;</span>
                    </summary>
                    <p className="text-xs text-slate-500 leading-relaxed mt-3 pt-3 border-t border-slate-100 font-medium">{faq.a}</p>
                  </details>
                ))}
              </div>
            </div>
          )}
        </main>
      </div>

      {/* 3. MODALS */}
      <AddGoodsModal
        isOpen={isAddGoodsOpen}
        onClose={() => setIsAddGoodsOpen(false)}
        storageUnits={storageUnits}
        onAddGoods={handleAddGoods}
      />

      <DrillDownModal
        isOpen={isDrillDownOpen}
        onClose={() => setIsDrillDownOpen(false)}
        storageUnit={selectedStorageUnit}
        alert={selectedAlert}
        onResolveAlert={handleResolveAlert}
      />
    </div>
  );
}
