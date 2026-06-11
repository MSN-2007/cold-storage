"use client";

import React from "react";
import { Database, Thermometer, Droplet, Wind, FlaskConical } from "lucide-react";
import { StorageUnit } from "@/types";

interface StorageGridProps {
  storageUnits: StorageUnit[];
  onViewDetails: (su: StorageUnit) => void;
  activeFilter: string;
}

export default function StorageGrid({
  storageUnits,
  onViewDetails,
  activeFilter,
}: StorageGridProps) {
  // Filter storages in real-time based on active status cards
  const filteredUnits =
    activeFilter === "Total"
      ? storageUnits
      : storageUnits.filter((su) => su.status === activeFilter);

  const getStatusStyle = (status: string) => {
    switch (status) {
      case "Healthy":
        return {
          text: "text-emerald-600",
          bg: "bg-emerald-50",
          border: "border-emerald-200",
          bar: "bg-emerald-500 shadow shadow-emerald-500/10",
        };
      case "Warning":
        return {
          text: "text-amber-500",
          bg: "bg-amber-50",
          border: "border-amber-200",
          bar: "bg-amber-400 shadow shadow-amber-400/10",
        };
      case "Critical":
        return {
          text: "text-red-600",
          bg: "bg-red-50",
          border: "border-red-200",
          bar: "bg-red-500 shadow shadow-red-500/10",
        };
      default:
        return {
          text: "text-slate-600",
          bg: "bg-slate-50",
          border: "border-slate-200",
          bar: "bg-slate-500",
        };
    }
  };

  return (
    <div id="storages-grid-section" className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-extrabold text-slate-900 tracking-tight">Your Cold Storages</h2>
        <button
          onClick={() => alert("Viewing full storage grid list")}
          className="text-sm font-bold text-accent hover:text-emerald-700 flex items-center gap-1 transition"
        >
          View All Storages &rarr;
        </button>
      </div>

      {filteredUnits.length === 0 ? (
        <div className="bg-white border border-dashed border-slate-200 rounded-3xl p-12 text-center max-w-xl mx-auto space-y-3">
          <div className="bg-slate-50 w-14 h-14 rounded-full flex items-center justify-center mx-auto text-slate-400 border border-slate-100">
            <Database className="w-6 h-6 animate-pulse" />
          </div>
          <p className="text-base font-extrabold text-slate-700">No matching storage units found</p>
          <p className="text-xs text-slate-400 leading-relaxed">
            There are currently no chambers matching the active status filter "{activeFilter}". Tap
            another card to browse.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {filteredUnits.map((su) => {
            const style = getStatusStyle(su.status);
            return (
              <div
                id={`storage-card-${su.id}`}
                key={su.id}
                className="bg-white border border-slate-200/80 rounded-2xl p-5 shadow-sm hover:shadow-md transition-all duration-200 flex flex-col justify-between"
              >
                <div>
                  {/* Card Title & Info */}
                  <div className="flex justify-between items-start mb-4">
                    <div>
                      <div className="flex items-center gap-2 mb-1.5 flex-wrap">
                        <h3 className="font-extrabold text-slate-900 text-base tracking-tight">
                          {su.name}
                        </h3>
                        <span
                          className={`text-[9px] font-extrabold px-2 py-0.5 rounded-full border uppercase tracking-wider ${style.bg} ${style.border} ${style.text}`}
                        >
                          {su.status}
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-500 font-semibold uppercase tracking-wider">
                        Active &bull; {su.chambers} Chamber{su.chambers > 1 ? "s" : ""}
                      </p>
                      <p className="text-xs text-slate-400 font-bold mt-1 truncate max-w-[150px]">
                        {su.crops}
                      </p>
                    </div>
                    <div className="p-2.5 bg-slate-50 border border-slate-100 rounded-xl flex-shrink-0 text-slate-300">
                      <Database className="w-6 h-6" strokeWidth={1.5} />
                    </div>
                  </div>

                  {/* Health Bar Slider */}
                  <div className="my-5">
                    <div className="flex items-center justify-between text-[11px] font-extrabold text-slate-400 mb-1.5 uppercase tracking-wider">
                      <span>Overall Health</span>
                      <span className={style.text}>{su.health}%</span>
                    </div>
                    <div className="h-2.5 bg-slate-100 rounded-full overflow-hidden">
                      <div
                        id={`storage-card-healthbar-${su.id}`}
                        className={`h-full ${style.bar} rounded-full transition-all duration-500`}
                        style={{ width: `${su.health}%` }}
                      />
                    </div>
                  </div>

                  {/* Sensor Stats Grid */}
                  <div className="grid grid-cols-4 gap-1.5 mb-5 bg-slate-50/50 p-2.5 rounded-xl border border-slate-100">
                    {/* Temperature */}
                    <div className="flex flex-col items-center text-center">
                      <Thermometer className="w-3.5 h-3.5 text-red-400 mb-1" />
                      <span
                        id={`sensor-temp-${su.id}`}
                        className="font-extrabold text-[11px] text-slate-900 tracking-tight"
                      >
                        {su.metrics.temp}°C
                      </span>
                      <span className="text-[9px] text-slate-400 font-bold uppercase tracking-wider mt-0.5">
                        Temp
                      </span>
                    </div>

                    {/* Humidity */}
                    <div className="flex flex-col items-center text-center">
                      <Droplet className="w-3.5 h-3.5 text-blue-400 mb-1" />
                      <span
                        id={`sensor-hum-${su.id}`}
                        className="font-extrabold text-[11px] text-slate-900 tracking-tight"
                      >
                        {su.metrics.hum}%
                      </span>
                      <span className="text-[9px] text-slate-400 font-bold uppercase tracking-wider mt-0.5">
                        Humid
                      </span>
                    </div>

                    {/* CO2 */}
                    <div className="flex flex-col items-center text-center">
                      <Wind className="w-3.5 h-3.5 text-emerald-400 mb-1" />
                      <span
                        id={`sensor-co2-${su.id}`}
                        className="font-extrabold text-[11px] text-slate-900 tracking-tight"
                      >
                        {su.metrics.co2}
                      </span>
                      <span className="text-[9px] text-slate-400 font-bold uppercase tracking-wider mt-0.5">
                        CO₂ ppm
                      </span>
                    </div>

                    {/* Ethylene */}
                    <div className="flex flex-col items-center text-center">
                      <FlaskConical className="w-3.5 h-3.5 text-amber-400 mb-1" />
                      <span
                        id={`sensor-eth-${su.id}`}
                        className="font-extrabold text-[11px] text-slate-900 tracking-tight"
                      >
                        {su.metrics.eth}
                      </span>
                      <span className="text-[9px] text-slate-400 font-bold uppercase tracking-wider mt-0.5">
                        Eth ppm
                      </span>
                    </div>
                  </div>
                </div>

                {/* View Details Click */}
                <button
                  id={`btn-view-details-${su.id}`}
                  onClick={() => onViewDetails(su)}
                  className="w-full text-center text-xs font-bold text-accent hover:text-emerald-700 hover:bg-accent/5 py-2.5 rounded-xl border border-transparent hover:border-accent/15 transition-all duration-200"
                >
                  View Details &rarr;
                </button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
