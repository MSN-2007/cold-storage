"use client";

import React, { useState } from "react";
import { X, Box, Calendar, IndianRupee, Database, Plus } from "lucide-react";
import { StorageUnit } from "@/types";

interface AddGoodsModalProps {
  isOpen: boolean;
  onClose: () => void;
  storageUnits: StorageUnit[];
  onAddGoods: (
    storageId: string,
    batch: { cropName: string; quantity: string; entryDate: string; value: string }
  ) => void;
}

export default function AddGoodsModal({
  isOpen,
  onClose,
  storageUnits,
  onAddGoods,
}: AddGoodsModalProps) {
  const [selectedStorage, setSelectedStorage] = useState(storageUnits[0]?.id || "");
  const [cropName, setCropName] = useState("Tomato");
  const [customCrop, setCustomCrop] = useState("");
  const [quantity, setQuantity] = useState("");
  const [entryDate, setEntryDate] = useState(new Date().toISOString().split("T")[0]);
  const [marketValue, setMarketValue] = useState("");
  const [error, setError] = useState("");

  if (!isOpen) return null;

  const cropOptions = [
    "Tomato",
    "Potato",
    "Leafy Greens",
    "Carrot",
    "Banana",
    "Onion",
    "Apple",
    "Orange",
    "Other",
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const finalCropName = cropName === "Other" ? customCrop.trim() : cropName;

    if (!finalCropName) {
      setError("Please select or enter a crop name.");
      return;
    }
    if (!quantity || isNaN(Number(quantity)) || Number(quantity) <= 0) {
      setError("Please enter a valid quantity in kg.");
      return;
    }
    if (!marketValue || isNaN(Number(marketValue)) || Number(marketValue) <= 0) {
      setError("Please enter a valid market value in ₹.");
      return;
    }

    onAddGoods(selectedStorage, {
      cropName: finalCropName,
      quantity: `${Number(quantity).toLocaleString()} kg`,
      entryDate,
      value: `₹${Number(marketValue).toLocaleString()}`,
    });

    // Reset Form
    setCropName("Tomato");
    setCustomCrop("");
    setQuantity("");
    setMarketValue("");
    onClose();
  };

  return (
    <div
      id="add-goods-modal-overlay"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-fade-in"
    >
      <div
        id="add-goods-modal-container"
        className="bg-white rounded-3xl w-full max-w-lg shadow-2xl border border-slate-100 overflow-hidden transform transition-all duration-300 scale-100 flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-slate-900 text-white p-6 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="bg-accent/20 p-2 rounded-xl border border-accent/30 text-accent">
              <Box className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-extrabold text-lg tracking-tight">Add Inventory Batch</h3>
              <p className="text-slate-400 text-xs mt-0.5">Deposit new batch into cold chamber</p>
            </div>
          </div>
          <button
            id="close-add-goods-modal"
            onClick={onClose}
            className="text-slate-400 hover:text-white hover:bg-slate-800 p-2 rounded-xl transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-5 flex-1 overflow-y-auto">
          {error && (
            <div
              id="add-goods-error-message"
              className="bg-red-50 border border-red-200 text-red-700 text-xs font-semibold px-4 py-3 rounded-xl flex items-center gap-2"
            >
              <div className="w-1.5 h-1.5 rounded-full bg-red-500 animate-ping" />
              <span>{error}</span>
            </div>
          )}

          {/* Storage Unit Select */}
          <div className="space-y-2">
            <label className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
              <Database className="w-3.5 h-3.5" /> Destination Storage Unit
            </label>
            <select
              id="select-storage-unit"
              value={selectedStorage}
              onChange={(e) => setSelectedStorage(e.target.value)}
              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-800 focus:outline-none focus:border-accent transition"
            >
              {storageUnits.map((su) => (
                <option key={su.id} value={su.id}>
                  {su.name} ({su.crops}) — Health: {su.health}%
                </option>
              ))}
            </select>
          </div>

          {/* Crop Profile Select */}
          <div className="space-y-2">
            <label className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
              <Box className="w-3.5 h-3.5" /> Crop Profile Type
            </label>
            <div className="grid grid-cols-3 gap-2">
              {cropOptions.slice(0, 8).map((crop) => (
                <button
                  type="button"
                  key={crop}
                  onClick={() => setCropName(crop)}
                  className={`py-2 px-3 border rounded-xl text-xs font-bold transition ${
                    cropName === crop
                      ? "bg-accent/10 border-accent text-accent"
                      : "border-slate-200 text-slate-600 hover:border-slate-300 bg-white"
                  }`}
                >
                  {crop}
                </button>
              ))}
              <button
                type="button"
                onClick={() => setCropName("Other")}
                className={`py-2 px-3 border rounded-xl text-xs font-bold transition ${
                  cropName === "Other"
                    ? "bg-accent/10 border-accent text-accent"
                    : "border-slate-200 text-slate-600 hover:border-slate-300 bg-white"
                }`}
              >
                Other...
              </button>
            </div>

            {cropName === "Other" && (
              <input
                id="input-custom-crop"
                type="text"
                value={customCrop}
                onChange={(e) => setCustomCrop(e.target.value)}
                placeholder="Enter custom crop type (e.g. Oranges)"
                className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-semibold text-slate-800 placeholder-slate-400 focus:outline-none focus:border-accent transition mt-2 animate-fade-in"
              />
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            {/* Quantity */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                Batch Weight (kg)
              </label>
              <div className="relative">
                <input
                  id="input-batch-quantity"
                  type="number"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  placeholder="e.g. 15000"
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-4 pr-10 py-3 text-sm font-bold text-slate-800 placeholder-slate-400 focus:outline-none focus:border-accent transition"
                />
                <span className="absolute right-3.5 top-3.5 text-xs font-bold text-slate-400">
                  kg
                </span>
              </div>
            </div>

            {/* Market Value */}
            <div className="space-y-2">
              <label className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                Market Value (₹)
              </label>
              <div className="relative">
                <input
                  id="input-market-value"
                  type="number"
                  value={marketValue}
                  onChange={(e) => setMarketValue(e.target.value)}
                  placeholder="e.g. 350000"
                  className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-8 pr-4 py-3 text-sm font-bold text-slate-800 placeholder-slate-400 focus:outline-none focus:border-accent transition"
                />
                <IndianRupee className="absolute left-3.5 top-3.5 w-3.5 h-3.5 text-slate-400" />
              </div>
            </div>
          </div>

          {/* Entry Date */}
          <div className="space-y-2">
            <label className="text-xs font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
              <Calendar className="w-3.5 h-3.5" /> Date of Entry
            </label>
            <input
              id="input-entry-date"
              type="date"
              value={entryDate}
              onChange={(e) => setEntryDate(e.target.value)}
              className="w-full bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-800 focus:outline-none focus:border-accent transition"
            />
          </div>

          {/* Buttons */}
          <div className="flex gap-3 pt-4 border-t border-slate-100">
            <button
              id="btn-cancel-add-goods"
              type="button"
              onClick={onClose}
              className="flex-1 bg-slate-100 hover:bg-slate-200 text-slate-700 py-3.5 rounded-xl font-bold text-sm transition"
            >
              Cancel
            </button>
            <button
              id="btn-submit-add-goods"
              type="submit"
              className="flex-1 bg-accent hover:bg-emerald-600 text-white py-3.5 rounded-xl font-bold text-sm transition flex items-center justify-center gap-2 shadow-lg shadow-accent/15"
            >
              <Plus className="w-4 h-4" /> Deposit Batch
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
